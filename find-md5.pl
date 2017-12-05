#!/usr/bin/perl -w

if ($#ARGV != 0 ) {
	print "ERROR usage: find-md5.pl pngfile\n";
	exit(1);
}

$md5 = `md5sum "$ARGV[0]"`;
chomp($md5);
$md5 =~ s/^([^ ]*)[ \t]*.*$/$1/;

#print "$md5\n";
#print "$ARGV[0]\n";
 
open($in,'<', "md5db.txt") or die $!; 

while($line = <$in>)
{
	if ($line =~ m/^([^ ]*)[ \t]*(.*.png)/) {
		$file = $2;
		$hash = $1;
		if ($md5 eq $hash) {
			print "found $file\n";
		}
	}
}

close ($in); 

exit(0);
