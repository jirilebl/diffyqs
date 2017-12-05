#!/usr/bin/perl -w

sub filemd5 {
	$fname = $_[0];
	$md5 = `md5sum "$fname"`;
	chomp($md5);
	$md5 =~ s/^([^ ]*)[ \t]*.*$/$1/;
	
	return $md5;
}

sub find_md5_fname {
	$md5 = $_[0];

	open($inn,'<', "md5db.txt") or die $!; 

	while($line = <$inn>)
	{
		if ($line =~ m/^([^ ]*)[ \t]*(.*.png)/) {
			$file = $2;
			$hash = $1;
			if ($md5 eq $hash) {
				return $file;
			}
		}
	}

	close ($inn); 

	return "";
}

sub find_md5_count {
	$md5 = $_[0];

	open($inn,'<', "md5counts.txt") or die $!; 

	while($line = <$inn>)
	{
		chomp($line);
		if ($line =~ m/^[ \t]*([^ ]*)[ \t]*(.*)$/) {
			$hash = $2;
			$count = $1;
			if ($md5 eq $hash) {
				return $count;
			}
		}
	}

	close ($inn); 

	return 0;
}


print "\nRunning downscale.pl...\n"; 

if ($#ARGV != 0 ) {
	print "ERROR usage: downscale.pl the-html-file\n";
	exit(1);
}



$htmlfile = $ARGV[0];
print "HTML file: $htmlfile\n";

open($in,'<', $htmlfile) or die $!; 
open($out, '>' ,"out-$htmlfile") or die $!; 

$filesize = 0;
$filesremoved = 0;

while($line = <$in>)
{
	# after date print viewport
	if ($line =~ m/^\<meta name=.date/) {
		print $out $line;
		print $out "<meta name=\"viewport\" content=\"width=device-width\">\n";
	}
	if ($line =~ m/^(.*)(\<img.*)$/) {
		print $out $1;
		$rest = "$2\n";
		if ($rest =~ m/\>/) {
			print "ERROR, found close on same line";
			close ($in); 
			close ($out); 
			system ("rm out-$htmlfile");
			exit(1);
		}
		while (1) {
			$c = getc($in);

			if ($c eq ">") {
				$rest = "$rest$c";

				$docacheinline = 1;

				if ($rest =~ m/src="([^"]*)"/) {
					$thefile = $1;
				} else {
					print "ERROR: Can't extract filename\n";
					print "the code is:\n";
					print $rest;
					print "\nend\n";
					close ($in); 
					close ($out); 
					system ("rm out-$htmlfile");
					exit(1);
				}

				if ($thefile =~ m/^diffyqs.*\.png$/) {
				} elsif ($thefile =~ m/.*-tex4ht\.png$/) {
					$docacheinline = 0;
				} else {
					print "Another img (leaving alone): $thefile\n";
					print $out $rest;
					last;

				}

				print "working on $thefile";

				if ( ! -e $thefile) {
					print "FILE DOESN'T EXIST!";
					close ($in); 
					close ($out); 
					system ("rm out-$htmlfile");
					exit(1);
				}

				print(".");

				if ($rest =~ m/ width=\"/ &&
					$rest =~ m/ height=\"/) {
					# don't do anything we already specified size
				} else {
					$fileline = `file $thefile`;
					print(".");

					if ($fileline =~ m/ ([0-9]+) x ([0-9]+),/) {
						$w = int($1/2 + 0.5);
						$h = int($2/2 + 0.5);
						print "(scaling $1 x $2 -> $w x $h)";
						$rest =~ s/\>/ width=\"$w\" height=\"$h\"\>/;
					} else {
						print "(no size?)";
					}
				}

				print(".");

				if ($docacheinline) {
					$filesize = -s $thefile;
					$filehash = filemd5($thefile);
					$count = find_md5_count($filehash);
					if ($count == 0) {
						print "FILE DOESN'T EXIST in md5db.txt but it should!";
						close ($in); 
						close ($out); 
						system ("rm out-$htmlfile");
						exit(1);
					}

					if ($count > 0 && $filesize < 2000/$count) {
						print("(inlined $thefile)");
						$base64=`base64 -w 10000 $thefile`;
						$rest =~ s/src=\"[^"]*\"/src=\"data:image\/png;base64,$base64\"/;
						system("rm $thefile");
					} else {
						$newthefile = find_md5_fname($filehash);
						if ($newthefile ne "" &&
							$newthefile ne $thefile) {
							$rest =~ s/src=\"[^"]*\"/src=\"$newthefile\"/;
							$filesize = $filesize + ( -s $thefile);
							$filesremoved = $filesremoved + 1;

							system("rm $thefile");
							print("(removed dup of $newthefile)");
						}
					}
				}

				print(".");

				print $out $rest;

				print(".");

				print "\n";

				last;
			}
			$rest = "$rest$c";
		}
	} else {
		print $out $line;
	}
}

print "saved $filesize bytes removing $filesremoved files\n";

close ($in); 
close ($out); 

print "Moving out to original\n";
system ("mv -f out-$htmlfile $htmlfile");

print "Done!\n\n"; 

exit(0);
