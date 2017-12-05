#!/usr/bin/perl -w
print "\nRunning objectify.pl...\n"; 

if ($#ARGV != 0 ) {
	print "ERROR usage: objectify.pl the-html-file\n";
	exit(1);
}

$htmlfile = $ARGV[0];
print "HTML file: $htmlfile\n";
 
open($in,'<', $htmlfile) or die $!; 
open($out, '>' ,"out-$htmlfile") or die $!; 

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
			exit(1);
		}
		while (1) {
			$c = getc($in);

			if ($c eq ">") {
				$rest = "$rest$c";
				#print "found\n";
				#print $rest;
				#print "done\n";

				if ($rest =~ m/src="([^"]*)"/) {
					$thefile = $1;
				} else {
					print "ERROR: Can't extract filename\n";
					print "the code is:\n";
					print $rest;
					print "\nend\n";
					exit(1);
				}

				$doconvert = 1;

				if ($thefile =~ m/\.svg$/) {
					$thefilepng = $thefile;
					$thefilepng =~ s/\.svg/\.png/;

				} elsif ($thefile =~ m/-tex4ht\.png$/) {
					$thefilepng = $thefile;
					$thefile =~ s/\.png/\.svg/;
					$doconvert = 0;
				} else {
					print "Another img (leaving alone): $thefile\n";
					print $out $rest;
					last;

				}


				$gotclass = 1;
				if ($rest =~ m/class="([^"]*)"/) {
					$theclass = $1;
				} else {
					$gotclass = 0;
					#print "ERROR: Can't extract class\n";
					#print "the code is:\n";
					#print $rest;
					#print "\nend\n";
					#exit(1);
				}

				$rest =~ s/\.svg/\.png/;

				print "working on $thefile";

				#print "file: $thefile $thefilepng class: $theclass\n";

				if ($gotclass) {
					print $out "<object data=\"$thefile\" type=\"image/svg+xml\" class=\"$theclass\">";
				} else {
					print $out "<object data=\"$thefile\" type=\"image/svg+xml\">";
				}

				print $out $rest;
				print $out "</object>";

				print(".");

				if ($doconvert) {
					system("rsvg $thefile $thefilepng");
					print(".");
				}

				print "\n";

				last;
			}
			$rest = "$rest$c";
		}
	} else {
		print $out $line;
	}
}

close ($in); 
close ($out); 

open($out, '>>' ,"diffyqs.css") or die $!; 
print $out "object.math{vertical-align:middle;}\n";
close ($out); 

print "Moving out to original\n";
system ("mv -f out-$htmlfile $htmlfile");

print "Done!\n\n"; 

exit(0);
