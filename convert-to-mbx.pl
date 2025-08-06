#!/usr/bin/perl
#
# Script to convert this particular LaTeX file to Pretext or PTX (used to be Mathbook or MBX)
#
# I assume this could be adapted to other projects, but it would need to be heavily modified.
# It does not read arbitrary latex.
#
print "running ...\n"; 

$num_errors = 0;

my @ins;
 
open(my $in,'<', "diffyqs.tex") or die $!; 
open(my $out, '>' ,"diffyqs-out.xml") or die $!; 
 
$mbxignore = 0;

$commands = "";

print $out <<END;
<?xml version="1.0" encoding="UTF-8" ?>
<pretext>
END

$docinfoextra = "";
$macrosextra = "";

# No \input file reading here (FIXME?)
while($line = <$in>)
{
	chomp($line);
	if ($line =~ m/^%mbxFIXME/) {
		printf("\n\n\nHUH?? FOUND mbxFIXME!\n\n\n");
		$num_errors++;
	} elsif ($line =~ m/^%mbxSTARTIGNORE/) {
		$mbxignore = 1;
	} elsif ($line =~ m/^%mbxENDIGNORE/) {
		$mbxignore = 0;
	} elsif ($line =~ m/^%mbx[ \t](.*)$/) {
		print $out "$1\n";
	} elsif ($line =~ m/^%mbxdocinfo[ \t](.*)$/) {
		$docinfoextra = $docinfoextra . "$1\n";
	} elsif ($line =~ m/^%mbxmacro[ \t](.*)$/) {
		$macrosextra = $macrosextra . "$1\n";
	} elsif ($line =~ m/^\\begin\{document\}/) {
		printf ("found begin document\n");
		last;
	} elsif ($mbxignore == 0 && $line =~ m/^\\renewcommand/) {
		$commands = $commands . "$line\n";
	} elsif ($mbxignore == 0 && $line =~ m/^\\newcommand/) {
		$commands = $commands . "$line\n";
	}
}

print $out "<docinfo>\n";

if ($docinfoextra ne "") {
	print $out $docinfoextra;
}

if ($commands ne "" || $macrosextra ne "") {
	print $out "  <macros>\n";
	print $out $commands;
	print $out $macrosextra;
	print $out "  </macros>\n";
}

print $out "</docinfo>\n";
print $out "<book xml:id=\"diffyqs\">\n";

$didp = 0;
$inchapter = 0;
$insection = 0;
$insubsection = 0;
$insubsubsection = 0;
$initem = 0;
$inparagraph = 0;

$chapter_num = 0;
$section_num = 0;
$subsection_num = 0;
$subsubsection_num = 0;
$in_appendix = 0;

$exercise_num = 0;
$thm_num = 0;
$remark_num = 0;
$example_num = 0;
$figure_num = 0;
$table_num = 0;

#FIXME: equation counter implement
$equation_num = 0;

$list_level = 0;
$list_start = 1;

#print $out $commands;

sub close_paragraph {
	if ($inparagraph) {
		$inparagraph = 0;
		print $out "</p>\n"
	}
}
sub close_item {
	close_paragraph ();
	if ($initem) {
		$initem = 0;
		print $out "</li>\n"
	}
}
sub close_subsubsection {
	close_paragraph ();
	if ($insubsubsection == 2) {
		$insubsubsection = 0;
		print $out "</introduction>\n\n"
	} elsif ($insubsubsection) {
		$insubsubsection = 0;
		print $out "</subsubsection>\n\n"
	}
}
sub close_subsection {
	close_subsubsection ();
	if ($insubsection == 2) {
		$insubsection = 0;
		print $out "</introduction>\n\n"
	} elsif ($insubsection == 3) {
		$insubsection = 0;
		print $out "</exercises>\n\n"
	} elsif ($insubsection) {
		$insubsection = 0;
		print $out "</subsection>\n\n"
	}
}
sub close_section {
	close_subsection();
	if ($insection) {
		$insection = 0;
		print $out "</section>\n\n"
	}
}
sub close_chapter {
	close_section ();
	if ($inchapter) {
		$inchapter = 0;
		if ($in_appendix == 0) {
			print $out "</chapter>\n\n"
		} else {
			print $out "</appendix>\n\n"
		}
	}
}
sub open_paragraph {
	close_paragraph ();
	$inparagraph = 1;
	print $out "<p>\n"
}
sub open_paragraph_if_not_open {
	if ($inparagraph == 0) {
		$inparagraph = 1;
		print $out "<p>\n"
	}
}
sub open_item {
	close_item ();
	$initem = 1;
	print $out "<li>\n"
}
sub get_chapter_num {
	if ($in_appendix == 0) {
	  	return "$chapter_num";
	} else {
		if ($chapter_num == 1) { return "A"; }
		elsif ($chapter_num == 2) { return "B"; }
		elsif ($chapter_num == 3) { return "C"; }
		elsif ($chapter_num == 4) { return "D"; }
		elsif ($chapter_num == 5) { return "E"; }
		print "\n\n\nHUH? too many appendices ($chapter_num)\n\n\n";
		$num_errors++;
	}
}
sub open_subsubsection {
	my $theid = shift;
	my $name = shift;
	close_subsubsection ();
	$insubsubsection = 1;
	$subsubsection_num = $subsubsection_num+1;

	my $ch = get_chapter_num();

	if ($theid ne "") {
		print $out "\n<subsubsection xml:id=\"$theid\" number=\"$ch.$section_num.$subsection_num.$subsubsection_num\">\n"
	} else {
		print $out "\n<subsubsection number=\"$ch.$section_num.$subsection_num.$subsubsection_num\">\n"
	}

	print "(subsubsection >$name< label >$theid<)\n";
	print $out "<title>$name</title>\n"; 
}
sub open_intro_subsubsection {
	$insubsubsection = 2;

	print "(intro subsubsection)\n";
	print $out "\n<introduction>\n";
}
sub open_subsection {
	my $theid = shift;
	my $name = shift;
	close_subsection ();
	$insubsection = 1;
	$subsection_num = $subsection_num+1;

	$subsubsection_num = 0;

	my $ch = get_chapter_num();

	if ($theid ne "") {
		print $out "\n<subsection xml:id=\"$theid\" number=\"$ch.$section_num.$subsection_num\">\n"
	} else {
		print $out "\n<subsection number=\"$ch.$section_num.$subsection_num\">\n"
	}

	print "(subsection >$name< label >$theid<)\n";
	print $out "<title>$name</title>\n"; 

	# Don't open an intro subsubsection, that's done manually with %mbxINTROSUBSUBSECTION
}
sub open_intro_subsection {
	$insubsection = 2;

	print "(intro subsection)\n";
	print $out "\n<introduction>\n";
}
sub open_exercise_subsection {
	close_subsection ();
	$insubsection = 3;
	$subsection_num = $subsection_num+1;

	$subsubsection_num = 0;

	my $ch = get_chapter_num();


	print "(exercises subsection)\n";
	print $out "\n<exercises number=\"$ch.$section_num.$subsection_num\">\n"
}
sub open_section {
	my $theid = shift;
	my $name = shift;
	close_section ();
	$insection = 1;
	$section_num = $section_num+1;

	$subsection_num = 0;
	$subsubsection_num = 0;

	$exercise_num = 0;
	$thm_num = 0;
	$remark_num = 0;
	$example_num = 0;

	my $ch = get_chapter_num();

	if ($theid ne "") {
		print $out "\n<section xml:id=\"$theid\" number=\"$ch.$section_num\">\n"
	} else {
		print $out "\n<section number=\"$ch.$section_num\">\n"
	}

	print "(section >$name< label >$theid<)\n";
	print $out "<title>$name</title>\n"; 

	# Don't open an intro subsection, that's done manually with %mbxINTROSUBSECTION
	#open_intro_subsection();
}

sub open_chapter {
	my $theid = shift;
	close_chapter ();
	$inchapter = 1;

	$chapter_num = $chapter_num+1;
	$section_num = 0;
	$subsection_num = 0;
	$subsubsection_num = 0;

	$exercise_num = 0;
	$thm_num = 0;
	$remark_num = 0;
	$example_num = 0;

	$equation_num = 0;
	$figure_num = 0;
	$table_num = 0;

	my $ch = get_chapter_num();

	if ($in_appendix == 0) {
		if ($theid ne "") {
			print $out "\n<chapter xml:id=\"$theid\" number=\"$ch\">\n"
		} else {
			print $out "\n<chapter number=\"$ch\">\n"
		}
	} else {
		if ($theid ne "") {
			print $out "\n<appendix xml:id=\"$theid\" number=\"$ch\">\n"
		} else {
			print $out "\n<appendix number=\"$ch\">\n"
		}
	}
}

sub modify_id {
	my $theid = shift;
	$theid =~ s/^([0-9])/X$1/;
	$theid =~ s/:/_/g;
	$theid =~ s/\./_/g;
	return $theid;
}

sub do_line_subs {
	my $line = shift;

	if ($line =~ s|~|<nbsp/>|g) {
		print "substituted nbsps\n";
	}
	if ($line =~ s|---|&#x2014;|g) {
		print "substituted emdashes\n";
	}
	if ($line =~ s|--|&#x2013;|g) {
		print "substituted endashes\n";
	}
	##FIXME: should we do this?
	#if ($line =~ s|-|&#x2010;|g) {
	#print "substituted hyphens\n";
	#}
	
	return $line;
}


sub do_ref_subs {
	my $str = shift;
	$str =~ s|\\Chapterref\{([^}]*)\}|'<xref ref="' . modify_id($1) . '" text="type-global"/>'|eg;
	$str =~ s|\\chapterref\{([^}]*)\}|'<xref ref="' . modify_id($1) . '" text="type-global"/>'|eg;
	$str =~ s|\\chaptervref\{([^}]*)\}|'<xref ref="' . modify_id($1) . '" text="type-global"/>'|eg;
	$str =~ s|\\appendixref\{([^}]*)\}|'<xref ref="' . modify_id($1) . '" text="type-global"/>'|eg;
	$str =~ s|\\appendixvref\{([^}]*)\}|'<xref ref="' . modify_id($1) . '" text="type-global"/>'|eg;
	$str =~ s|\\Appendixref\{([^}]*)\}|'<xref ref="' . modify_id($1) . '" text="type-global"/>'|eg;
	$str =~ s|\\sectionref\{([^}]*)\}|'<xref ref="' . modify_id($1) . '" text="type-global"/>'|eg;
	$str =~ s|\\sectionvref\{([^}]*)\}|'<xref ref="' . modify_id($1) . '" text="type-global"/>'|eg;
	$str =~ s|\\subsectionref\{([^}]*)\}|'<xref ref="' . modify_id($1) . '" text="type-global"/>'|eg;
	$str =~ s|\\subsectionvref\{([^}]*)\}|'<xref ref="' . modify_id($1) . '" text="type-global"/>'|eg;
	$str =~ s|\\thmref\{([^}]*)\}|'<xref ref="' . modify_id($1) . '" text="type-global"/>'|eg;
	$str =~ s|\\thmvref\{([^}]*)\}|'<xref ref="' . modify_id($1) . '" text="type-global"/>'|eg;
	$str =~ s|\\remarkref\{([^}]*)\}|'<xref ref="' . modify_id($1) . '" text="type-global"/>'|eg;
	$str =~ s|\\remarkvref\{([^}]*)\}|'<xref ref="' . modify_id($1) . '" text="type-global"/>'|eg;
	$str =~ s|\\tableref\{([^}]*)\}|'<xref ref="' . modify_id($1) . '" text="type-global"/>'|eg;
	$str =~ s|\\tablevref\{([^}]*)\}|'<xref ref="' . modify_id($1) . '" text="type-global"/>'|eg;
	$str =~ s|\\figureref\{([^}]*)\}|'<xref ref="' . modify_id($1) . '" text="type-global"/>'|eg;
	$str =~ s|\\figurevref\{([^}]*)\}|'<xref ref="' . modify_id($1) . '" text="type-global"/>'|eg;
	$str =~ s|\\exampleref\{([^}]*)\}|'<xref ref="' . modify_id($1) . '" text="type-global"/>'|eg;
	$str =~ s|\\examplevref\{([^}]*)\}|'<xref ref="' . modify_id($1) . '" text="type-global"/>'|eg;
	$str =~ s|\\exerciseref\{([^}]*)\}|'<xref ref="' . modify_id($1) . '" text="type-global"/>'|eg;
	$str =~ s|\\exercisevref\{([^}]*)\}|'<xref ref="' . modify_id($1) . '" text="type-global"/>'|eg;
	return $str;
}

sub print_line {
	my $line = shift;

	if ($inparagraph == 0 && $line =~ m/[^ \r\n\t]/) {
		open_paragraph ();
	}
	$line = do_line_subs($line);
	print "line -- >$line<\n";
	print $out $line;
}

sub do_thmtitle_subs {
	my $title = shift;

	$title =~ s|\\href\{(.*?)\}\{(.*?)\}|<url href=\"$1\" visual=\"$1\">$2</url>|gs;

	$title = do_line_subs($title);

	#FIXME: should check if multiple footnotes work
	while ($title =~ s!\\footnote\{([^{}]*|([^{}]*\{[^{}]*\}[^{}]*)*)\}!<fn>$1</fn>!s) {
		;
	}

	return $title;
}

sub get_exercise_number {
	my $ch = get_chapter_num();
	if ($insection) {
		return "$ch.$section_num.$exercise_num";
	} elsif ($inchapter) {
		return "$ch.$exercise_num";
	} else {
		return "$exercise_num";
	}
}

sub get_thm_number {
	my $ch = get_chapter_num();
	if ($insection) {
		return "$ch.$section_num.$thm_num";
	} elsif ($inchapter) {
		return "$ch.$thm_num";
	} else {
		return "$thm_num";
	}
}

sub get_remark_number {
	my $ch = get_chapter_num();
	if ($insection) {
		return "$ch.$section_num.$remark_num";
	} elsif ($inchapter) {
		return "$ch.$remark_num";
	} else {
		return "$remark_num";
	}
}

sub get_example_number {
	my $ch = get_chapter_num();
	if ($insection) {
		return "$ch.$section_num.$example_num";
	} elsif ($inchapter) {
		return "$ch.$example_num";
	} else {
		return "$example_num";
	}
}

sub get_figure_number {
	my $ch = get_chapter_num();
	if ($inchapter and not $ch eq "0") {
		return "$ch.$figure_num";
	} else {
		return "$figure_num";
	}
}

sub get_table_number {
	my $ch = get_chapter_num();
	if ($inchapter and not $ch eq "0") {
		return "$ch.$table_num";
	} else {
		return "$table_num";
	}
}

sub get_equation_number {
	my $ch = get_chapter_num();
	if ($inchapter and not $ch eq "0") {
		return "$ch.$equation_num";
	} else {
		return "$equation_num";
	}
}

sub get_size_of_svg {
	my $thefile = shift;

	open (my $svgf, '<', $thefile) or return "";

	$thesizestr = "";

	while (my $line = <$svgf> ) {
		chomp($line);
		if ($line =~ m{^<svg}) {
			if ($line =~ m{^<[^>]*(width=["'][^"']*["']) *(height=["'][^"]*["'])}) {
				$thesizestr = "$1 $2";
				$thesizestr =~ s/'/"/g;

				# If units missing, add them
				$thesizestr =~ s/"([0-9.]*)"/"${1}px"/;
				$thesizestr =~ s/"([0-9.]*)"/"${1}px"/;
			}

			last;
		}
	}

	close $svgf;

	print "the size string of $thefile >$thesizestr<\n";
	return $thesizestr;
}

sub ensure_mbx_svg_version {
	my $thefile = shift;

	print "ENSURE $thefile-mbx.svg\n";
	if ((not -e "$thefile-mbx.svg") and (-e "$thefile.pdf")) {
		print "MAKING $thefile-mbx.svg from PDF\n";
		system("pdftocairo -svg $thefile.pdf $thefile-mbx.svg");
		system("svgo $thefile-mbx.svg");
	}
}

#sub ensure_mbx_png_version {
#	my $thefile = shift;
#
#	print "ENSURE $thefile-mbx.png\n";
#	if ((not -e "$thefile-mbx.png") and (-e "$thefile.pdf")) {
#		print "MAKING $thefile-mbx.png from PDF\n";
#		system("./pdftopng.sh $thefile.pdf $thefile-mbx.png 192");
#	}
#}

sub do_displaymath_subs {
	my $eqn = shift;

	$eqn =~ s/\\displaybreak\[0\]//g;
	$eqn =~ s/\\avoidbreak[\r\n]*//g;
	$eqn =~ s/\\pagebreak\[[0-9]\][\r\n]*//g;

	return $eqn;
}

sub read_paragraph {
	my $para = "";
	my $read_something = 0;
	while(1) {
		my $line = <$in>;
		if ( ! defined $line) {
			print "FOUND END OF FILE\n";
			if (@ins) {
				print "END OF input FILE\n))))\n\n";
				close($in);
				$in = pop @ins;
				next;
			} else {
				# This shouldsn't happen, we should have found and end of document
				print "END OF MAIN FILE\n))))\n\n";
				print "ERROR: no \\end{document} found so faking it\n\n";
				$num_errors++;
				$para = $para .  "\n\\end{document}";
			}
		}

		chomp($line);

		#things that should go into the mbx to be processed (not raw MBX
		#as %mbx) but should be ignored by latex
		$line =~ s/^%mbxlatex //;

		if ($line =~ m/^%mbxFIXME/) {
			printf("\n\n\nFOUND mbxFIXME!\n\n\n");
			$num_errors++;
		} elsif ($line =~ m/^%mbxSTARTIGNORE/) {
			$mbxignore = 1;
		} elsif ($line =~ m/^%mbxENDIGNORE/) {
			$mbxignore = 0;

		} elsif ($mbxignore == 0 &&
			 ($line =~ m/^[ \t]*\\input[ \t][ \t]*(.*)$/ ||
			  $line =~ m/^[ \t]*\\input\{(.*)\}.*$/)) {
			 my $thefile = $1;
			 push @ins, $in;
			 undef $in;
			 print "\n((((\nFOUND \\input $thefile\n";
			 if ( ! open($in,'<', $thefile)) {
				 print "\n\nHUH???\n\nThere is an \\input $thefile ... but I can't open \"$thefile\"\n\n))))\n\n";

				 $num_errors++;

				 $in = pop @ins;
			 }

		#This will only work right if the paragraphs are separated, that is if it is
		#in the middle of a paragraph it put the %mbx line in the wrong place
		} elsif ($line =~ m/^%mbx[ \t](.*)$/) {
			my $thembxline = $1;
			#FIXME: this is a terrible hack, but the only way I can get this
			#hardcoded number stuff to work
			#This will only work right if the paragraphs are separated, that is if it is
			#in the middle of a paragraph it will get the numbers wrong.
			while ($thembxline =~ m/%MBXEQNNUMBER%/) {
				$equation_num = $equation_num+1;
				$the_num = get_equation_number ();
				$thembxline =~ s/%MBXEQNNUMBER%/$the_num/;
			}
			print $out "$thembxline\n";
		} elsif ($line =~ m/^\\documentclass/ ||
			$line =~ m/^\\usepackage/ ||
			$line =~ m/^\\addcontentsline/) {
			# do nothing
			;
		} elsif ($line =~ m/^%mbxCLOSECHAPTER/) {
			close_chapter ();
		} elsif ($line =~ m/^%mbxINTROSUBSUBSECTION/) {
			open_intro_subsubsection ();
		} elsif ($line =~ m/^%mbxINTROSUBSECTION/) {
			open_intro_subsection ();
		} elsif ($mbxignore == 0) {
			my $newline = 1;
			if ($line =~ m/^%/ || $line =~ m/[^\\]%/) {
				$newline = 0;
			}
			$line =~ s/^%.*$//;
			$line =~ s/([^\\])%.*$/$1/;

			if ($line =~ m/^[ \t]*$/ && $newline) {
				if ($read_something) {
					$para = $para . $line; # . " ";
					last;
				}
			}

			$read_something = 1;

			if ($newline) {
				$para = $para . $line . "\n";
			} else {
				$para = $para . $line;
			}
		}
	}

	#Do simple substitutions, (these are incomplete, just the ones I actually used at some point)
	$para =~ s/\\"\{o\}/ö/g;
	$para =~ s/\\"o/ö/g;
	$para =~ s/\\\^o/ô/g;
	$para =~ s/\\"i/ï/g;
	$para =~ s/\\c\{S\}/Ş/g;
	$para =~ s/\\u\{g\}/ğ/g;
	$para =~ s/\\v\{r\}/ř/g;
	$para =~ s/\\c\{c\}/ç/g;
	$para =~ s/\\'e/é/g;
	$para =~ s/\\'\{e\}/é/g;
	$para =~ s/\\`e/è/g;
	$para =~ s/\\`\{e\}/è/g;
	$para =~ s/\\`a/à/g;
	$para =~ s/\\`\{a\}/à/g;
	$para =~ s/\\'a/á/g;
	$para =~ s/\\'o/ó/g;
	$para =~ s/\\'i/í/g;
	$para =~ s/\{\\i\}/ı/g;
	$para =~ s/\\'\{i\}/í/g;
	$para =~ s/\\'E/É/g;
	$para =~ s/\\'\{E\}/É/g;
	$para =~ s/\\S([^a-zA-Z])/§$1/g;

	$para =~ s/&/&amp;/g;
	$para =~ s/>/&gt;/g;
	$para =~ s/</&lt;/g;

	#strip leading and trailing spaces
	#$para =~ s/^ *//;
	#$para =~ s/[ \n]*$//;

	#Also strip some nonsensical spaces
	#$para =~ s/[ \n](\\end{(exercise|example|thm|equation|align|equation\*|align\*)})/$1/g;
	

	return $para;
}



@cltags = ();

while(1)
{
	if ($para eq "") {
		$para = read_paragraph ();
	}

	#print "\n\nparagraph: [[[$para]]]\n";

	if ($para =~ m/^\\end\{document\}/) {
		last;

	#copy whitespace
	} elsif ($para =~ s/^([ \n\r\t])//) {
		print $out "$1";

	} elsif ($para =~ s/^\$([^\$]+)\$//) {
		my $line = $1;
		open_paragraph_if_not_open ();
		print $out "<m>$line</m>";

	} elsif ($para =~ s/^\\chapter\*\{([^}]*)\}[\n ]*\\label\{([^}]*)\}[ \n]*//) {
		#FIXME: un-numbered
		my $name = do_line_subs($1);
		my $theid = modify_id($2);
		$name =~ s|\$(.*?)\$|<m>$1</m>|gs;
		$chapter_num = $chapter_num-1; #hack
		open_chapter($theid);
		print "(chapter >$name< label >$theid<)\n";
		print $out "<title>$name</title>\n"; 
		print "PARA:>$para<\n";
	} elsif ($para =~ s/^\\chapter\*\{([^}]*)\}[ \n]*//) {
		#FIXME: un-numbered
		my $name = do_line_subs($1);
		$chapter_num = $chapter_num-1; #hack
		$name =~ s|\$(.*?)\$|<m>$1</m>|gs;
		open_chapter("");
		print "(chapter >$name<)\n";
		print $out "<title>$name</title>\n"; 
	} elsif ($para =~ s/^\\chapter\{([^}]*)\}[\n ]*\\label\{([^}]*)\}[ \n]*//) {
		my $name = do_line_subs($1);
		my $theid = modify_id($2);
		$name =~ s|\$(.*?)\$|<m>$1</m>|gs;
		open_chapter($theid);
		print "(chapter >$name< label >$theid<)\n";
		print $out "<title>$name</title>\n"; 
	} elsif ($para =~ s/^\\chapter\{([^}]*)\}[ \n]*//) {
		my $name = do_line_subs($1);
		open_chapter("");
		$name =~ s|\$(.*?)\$|<m>$1</m>|gs;
		print "(chapter >$name<)\n";
		print $out "<title>$name</title>\n"; 
	} elsif ($para =~ s/^\\section\{([^}]*)\}[ \n]*\\label\{([^}]*)\}[ \n]*//) {
		my $name = do_line_subs($1);
		my $theid = modify_id($2);
		$name =~ s|\$(.*?)\$|<m>$1</m>|gs;
		open_section($theid,$name);
	} elsif ($para =~ s/^\\section\{([^}]*)\}[ \n]*//) {
		my $name = do_line_subs($1);
		$name =~ s|\$(.*?)\$|<m>$1</m>|gs;
		open_section("",$name);
	} elsif ($para =~ s/^\\subsection\{Exercises\}[ \n]*//) {
		open_exercise_subsection();
	} elsif ($para =~ s/^\\subsection\{([^}]*)\}[ \n]*\\label\{([^}]*)\}[ \n]*//) {
		my $name = do_line_subs($1);
		my $theid = modify_id($2);
		$name =~ s|\$(.*?)\$|<m>$1</m>|gs;
		open_subsection($theid,$name);
	} elsif ($para =~ s/^\\subsection\{([^}]*)\}[ \n]*//) {
		my $name = do_line_subs($1);
		$name =~ s|\$(.*?)\$|<m>$1</m>|gs;
		open_subsection("",$name);
	} elsif ($para =~ s/^\\subsubsection\{([^}]*)\}[ \n]*\\label\{([^}]*)\}[ \n]*//) {
		my $name = do_line_subs($1);
		my $theid = modify_id($2);
		$name =~ s|\$(.*?)\$|<m>$1</m>|gs;
		open_subsubsection($theid,$name);
	} elsif ($para =~ s/^\\subsubsection\{([^}]*)\}[ \n]*//) {
		my $name = do_line_subs($1);
		$name =~ s|\$(.*?)\$|<m>$1</m>|gs;
		open_subsubsection("",$name);

	# this assumes sectionnotes come in their own $para
	} elsif ($para =~ s/^\\sectionnotes\{(.*)\}[ \n\t]*//s) {
		my $secnotes = do_line_subs($1);
		$secnotes =~ s|\\cite\{([^}]*)\}|<xref ref=\"biblio-$1\"/>|g;
		$secnotes =~ s|\\BDref\{([^}]*)\}|$1|g;
		$secnotes =~ s|\\EPref\{([^}]*)\}|$1|g;
		$secnotes = do_ref_subs($secnotes);
		print "(secnotes $secnotes)\n";
		print "(cite $secnotes)\n";
		print $out "<p><em>Note: $secnotes</em></p>\n"; 

	} elsif ($para =~ s/^\\setcounter\{exercise\}\{(.*?)\}[ \n\t]*//s) {
		$exercise_num=$1;

	} elsif ($para =~ s/^\\href\{([^}]*)\}\{([^}]*)\}//) {
		open_paragraph_if_not_open ();
		print "(link $1 $2)\n";
		print $out "<url href=\"$1\" visual=\"$1\">$2</url>"; 
	} elsif ($para =~ s/^\\url\{([^}]*)\}//) {
		open_paragraph_if_not_open ();
		print "(url $1)\n";
		print $out "<url href=\"$1\" />"; 
	} elsif ($para =~ s/^\\cite\{([^}]*)\}//) {
		open_paragraph_if_not_open ();
		print "(cite $1)\n";
		print $out "<xref ref=\"biblio-$1\"/>"; 

	} elsif ($para =~ s/^\\index\{([^}]*)\}//) {
		# This might open paragraphs where we don't want to leading
		# to empty paragraphs at the beginning of sections.
		#open_paragraph_if_not_open ();
		print "(index $1)\n";
		my $index = do_line_subs($1);
		my $sortby = "";
		if ($index =~ s|^(.*)@(.*)$|$2|s) {
			$sortby = $1;
		}
		$index =~ s|\$(.*?)\$|<m>$1</m>|sg;
		if ($sortby eq "") {
			$index =~ s|^(.*)!(.*)$|<h>$1</h><h>$2</h>|s;
			print $out "<idx>$index</idx>"; 
		} else {
			if ($index =~ s|^(.*)!(.*)$|<h sortby="$sortby">$1</h><h>$2</h>|s) {
				print $out "<idx>$index</idx>"; 
			} else {
				print $out "<idx><h sortby=\"$sortby\">$index</h></idx>"; 
			}
		}
	} elsif ($para =~ s/^\\myindex\{([^}]*)\}//) {
		open_paragraph_if_not_open ();
		print "(myindex $1)\n";
		my $index = do_line_subs($1);
		$index =~ s|\$(.*?)\$|<m>$1</m>|sg;
		print $out "$index<idx>$index</idx>"; 

	} elsif ($para =~ s/^\\eqref\{([^}]*)\}//) {
		open_paragraph_if_not_open ();
		my $theid = modify_id($1);
		print "(eqref $theid)\n";
		print $out "<xref ref=\"$theid\"/>";
	} elsif ($para =~ s/^\\ref\{([^}]*)\}//) {
		open_paragraph_if_not_open ();
		my $theid = modify_id($1);
		print "(ref $theid)\n";
		print $out "<xref ref=\"$theid\"/>";
	} elsif ($para =~ s/^\\chapterref\{([^}]*)\}// ||
		$para =~ s/^\\chaptervref\{([^}]*)\}// ||
		$para =~ s/^\\Chapterref\{([^}]*)\}// ||
		$para =~ s/^\\appendixref\{([^}]*)\}// ||
		$para =~ s/^\\appendixvref\{([^}]*)\}// ||
		$para =~ s/^\\Appendixref\{([^}]*)\}// ||
		$para =~ s/^\\sectionref\{([^}]*)\}// ||
		$para =~ s/^\\sectionvref\{([^}]*)\}// ||
		$para =~ s/^\\subsectionref\{([^}]*)\}// ||
		$para =~ s/^\\subsectionvref\{([^}]*)\}// ||
		$para =~ s/^\\thmref\{([^}]*)\}// ||
		$para =~ s/^\\thmvref\{([^}]*)\}// ||
		$para =~ s/^\\remarkref\{([^}]*)\}// ||
		$para =~ s/^\\tableref\{([^}]*)\}// ||
		$para =~ s/^\\tablevref\{([^}]*)\}// ||
		$para =~ s/^\\figureref\{([^}]*)\}// ||
		$para =~ s/^\\figurevref\{([^}]*)\}// ||
		$para =~ s/^\\exampleref\{([^}]*)\}// ||
		$para =~ s/^\\examplevref\{([^}]*)\}// ||
		$para =~ s/^\\exerciseref\{([^}]*)\}// ||
		$para =~ s/^\\exercisevref\{([^}]*)\}//) {
		my $theid = modify_id($1);
		open_paragraph_if_not_open ();
		print "(named ref $theid)\n";
		print $out "<xref ref=\"$theid\" text=\"type-global\"/>";
	} elsif ($para =~ s/^\\hyperref\[(.*?)\]\{(.*?)\}//) {
		my $name = $2;
		my $theid = modify_id($1);
		open_paragraph_if_not_open ();
		print "(hyperref $theid $name)\n";
		print $out "<xref ref=\"$theid\" text=\"custom\">$name</xref>";
	} elsif ($para =~ s/^\\emph\{//) {
		print "(em start)\n";
		open_paragraph_if_not_open();
		print $out "<em>"; 
		push @cltags, "em";
	} elsif ($para =~ s/^\\myquote\{//) {
		print "(myquote start)\n";
		open_paragraph_if_not_open();
		print $out "<q>"; 
		push @cltags, "myquote";

	} elsif ($para =~ s/^\\textbf\{(.*?)\}//s) {
		print "(textbf $1)\n";
		open_paragraph_if_not_open ();
		print $out "<alert>$1</alert>";

	} elsif ($para =~ s/^\\texttt\{(.*?)\}//s) {
		print "(texttt $1)\n";
		open_paragraph_if_not_open ();
		print $out "<c>$1</c>"; 

	} elsif ($para =~ s/^\\unit\{(.*?)\}//s) {
		print "(unit $1)\n";
		open_paragraph_if_not_open ();
		print $out "$1"; 
	} elsif ($para =~ s/^\\unit\[(.*?)\]\{(.*?)\}//s) {
		my $txt = $1;
		my $unit = $2;
		$txt =~ s|\$(.*?)\$|<m>$1</m>|gs;
		print "(unit $txt $unit)\n";
		open_paragraph_if_not_open ();
		print $out "$txt $unit"; 
	} elsif ($para =~ s/^\\unitfrac\{(.*?)\}\{(.*?)\}//s) {
		print "(unitfrac $1/$2)\n";
		open_paragraph_if_not_open ();
		print $out "<m>\\nicefrac{\\text{$1}}{\\text{$2}}</m>"; 
	} elsif ($para =~ s/^\\unitfrac\[(.*?)\]\{(.*?)\}\{(.*?)\}//s) {
		my $txt = $1;
		my $unitnum = $2;
		my $unitden = $3;

		$txt =~ s|\$(.*?)\$|<m>$1</m>|gs;
		print "(unitfrac $txt $unitnum/$unitden)\n";
		open_paragraph_if_not_open ();
		print $out "$txt <m>\\nicefrac{\\text{$unitnum}}{\\text{$unitden}}</m>"; 

	} elsif ($para =~ s/^\\begin\{align\*\}[ \n]*//) {
		print "(ALIGN*)\n";
		if ($para =~ s/^(.*?)\\end\{align\*\}[ \n]*//s) {
			my $eqn = do_displaymath_subs($1);

			my $indexes = "";
			while ($eqn =~ s/\\myindex\{(.*?)\}/$1/) {
				$indexes = $indexes . "<idx>$1</idx>";
			}
			while ($eqn =~ s/\\index\{(.*?)\}//) {
				$indexes = $indexes . "<idx>$1</idx>";
			}
			$indexes = do_line_subs($indexes);

			#FIXME: Is wrapping in aligned all kosher?
			print $out "<me>$indexes\n";
			print $out "\\begin{aligned}\n";
			print "(wrapping in aligned) EQ = $eqn\n";
			print $out "$eqn";
			print $out "\\end{aligned}\n";
			print $out "</me>\n";
		} else {
			print "\n\n\nHUH?\n\n\nNo end align*!\n\n$para\n\n";
			$num_errors++;
		}
	} elsif ($para =~ s/^\\begin\{align\}[ \n]*//) {
		print "(ALIGN)\n";
		if ($para =~ s/^(.*?)\\end\{align\}[ \n]*//s) {
			my $eqn = do_displaymath_subs($1);
			#$theid = "";
			#if ($para =~ s/^ *\\label\{(.*?)\} *//) {
			#	$theid = $1;
			#}

			my $indexes = "";
			while ($eqn =~ s/\\myindex\{(.*?)\}/$1/) {
				$indexes = $indexes . "<idx>$1</idx>";
			}
			while ($eqn =~ s/\\index\{(.*?)\}//) {
				$indexes = $indexes . "<idx>$1</idx>";
			}
			$indexes = do_line_subs($indexes);

			print $out "<md>$indexes\n";
			print $out "<mrow>\n";

			#FIXME: this will mess up things with cases
			# But currently I only have one single {align} with numbers
			# that will need to get handled
			$eqn =~ s|\\\\|</mrow>\n<mrow>\n|g;
			print "EQ = $eqn\n";

			print $out "$eqn";

			print $out "</mrow>\n";
			print $out "</md>\n";
		} else {
			print "\n\n\nHUH?\n\n\nNo end align!\n\n$para\n\n";
			$num_errors++;
		}

	} elsif ($para =~ s/^\\begin\{multline\*\}[ \n]*//) {
		print "(MULTLINE*)\n";
		if ($para =~ s/^(.*?)\\end\{multline\*\}[ \n]*//s) {
			my $eqn = do_displaymath_subs($1);

			my $indexes = "";
			while ($eqn =~ s/\\myindex\{(.*?)\}/$1/) {
				$indexes = $indexes . "<idx>$1</idx>";
			}
			while ($eqn =~ s/\\index\{(.*?)\}//) {
				$indexes = $indexes . "<idx>$1</idx>";
			}
			$indexes = do_line_subs($indexes);

			print $out "<me latexenv=\"multline*\">$indexes\n";
			print "EQ(multline*) = $eqn\n";
			print $out "$eqn";
			print $out "</me>\n";
		} else {
			print "\n\n\nHUH?\n\n\nNo end multline*!\n\n$para\n\n";
			$num_errors++;
		}
	} elsif ($para =~ s/^\\begin\{multline\}[ \n]*//) {
		print "(MULTLINE)\n";
		if ($para =~ s/^(.*?)\\end\{multline\}[ \n]*//s) {
			my $eqn = do_displaymath_subs($1);
			my $theid = "";
			if ($eqn =~ s/^[ \n]*\\label\{(.*?)\}[ \n]*//s) {
				$theid = modify_id($1);
			}

			my $indexes = "";
			while ($eqn =~ s/\\myindex\{(.*?)\}/$1/) {
				$indexes = $indexes . "<idx>$1</idx>";
			}
			while ($eqn =~ s/\\index\{(.*?)\}//) {
				$indexes = $indexes . "<idx>$1</idx>";
			}
			$indexes = do_line_subs($indexes);

			$equation_num = $equation_num+1;
			my $the_num = get_equation_number ();

			if ($theid eq "") {
				print $out "<men number=\"$the_num\" latexenv=\"multline\">$indexes\n";
			} else {
				print $out "<men xml:id=\"$theid\" number=\"$the_num\" latexenv=\"multline\">$indexes\n";
			}
			print "EQ(multline) = $eqn\n";
			print $out "$eqn";
			print $out "</men>\n";
		} else {
			print "\n\n\nHUH?\n\n\nNo end multline!\n\n$para\n\n";
			$num_errors++;
		}

	} elsif ($para =~ s/^\\begin\{equation\*\}[ \n]*//) {
		print "(EQUATION*)\n";
		if ($para =~ s/^(.*?)\\end\{equation\*\}[ \n]*//s) {
			my $eqn = do_displaymath_subs($1);

			my $indexes = "";
			while ($eqn =~ s/\\myindex\{(.*?)\}/$1/) {
				$indexes = $indexes . "<idx>$1</idx>";
			}
			while ($eqn =~ s/\\index\{(.*?)\}//) {
				$indexes = $indexes . "<idx>$1</idx>";
			}
			$indexes = do_line_subs($indexes);

			print $out "<me>$indexes\n";
			print "EQ = $eqn\n";
			print $out "$eqn</me>\n";
		} else {
			print "\n\n\nHUH?\n\n\nNo end equation*!\n\n$para\n\n";
			$num_errors++;
		}
	} elsif ($para =~ s/^\\begin\{equation\}[ \n]*//) {
		print "(EQUATION)\n";
		if ($para =~ s/^(.*?)\\end\{equation\}[ \n]*//s) {
			my $eqn = do_displaymath_subs($1);
			my $theid = "";
			if ($eqn =~ s/^[ \n]*\\label\{(.*?)\}[ \n]*//s) {
				$theid = modify_id($1);
			}

			$eqn =~ s/\\displaybreak\[0\]//g;

			my $indexes = "";
			while ($eqn =~ s/\\myindex\{(.*?)\}/$1/) {
				$indexes = $indexes . "<idx>$1</idx>";
			}
			while ($eqn =~ s/\\index\{(.*?)\}//) {
				$indexes = $indexes . "<idx>$1</idx>";
			}
			$indexes = do_line_subs($indexes);

			$equation_num = $equation_num+1;
			my $the_num = get_equation_number ();

			if ($theid eq "") {
				print $out "<men number=\"$the_num\">$indexes\n";
			} else {
				print $out "<men xml:id=\"$theid\" number=\"$the_num\">$indexes\n";
			}
			print "EQ = $eqn\n";
			print $out "$eqn</men>\n";
		} else {
			print "\n\n\nHUH?\n\n\nNo end equation!\n\n$para\n\n";
			$num_errors++;
		}

	#FIXME: not all substitutions are made, so check if more processing needs to be done
	#on contents and/or caption
	} elsif ($para =~ s/^\\begin\{table\}(\[.*?\])?[ \n]*//) {
		print "(TABLE)\n";
		if ($para =~ s/^(.*?)\\end\{table\}[ \n]*//s) {
			my $table = $1;

			# FIXME possibly not ok within math?
			$table =~ s|~|<nbsp/>|g;

			my $caption = "";
			my $theid = "";
			if ($table =~ s/\\caption\{(.*?)[ \n]*\\label\{(.*?)\}\}[ \n]*//s) {
				$caption = $1;
				$theid = modify_id($2);
				$caption =~ s|\$(.*?)\$|<m>$1</m>|sg;
				$caption = do_ref_subs($caption);
			} else {
				print "\n\n\nHUH?\n\n\nNo caption/label!\n\n$para\n\n";
				$num_errors++;
			}
			my $tablealign = "left";
			if ($table =~ m/\\begin\{tabular\}.*r/) {
				$tablealign = "right";
				if ($table =~ m/\\begin\{tabular\}.*l/) {
					print "\n\n\nHUH?\n\n\nBoth left/right alignments in a table\n\n$para\n\n";
					$num_errors++;
				}
			}
			if ($table =~ m/\\begin\{tabular\}.*c/) {
				print "\n\n\nHUH?\n\n\nCenter alignment in a table not allowed yet\n\n$para\n\n";
				$num_errors++;
			}
			# kill centering and the rules and the tabular 
			$table =~ s/\\begin\{center\}[ \n]*//;
			$table =~ s/\\end\{center\}[ \n]*//;
			$table =~ s/\\capstart[ \n]*//g;
			$table =~ s/\\(mid|bottom|top)rule[ \n]*//g;
			$table =~ s/\\begin\{tabular\}.*[ \n]*//;
			$table =~ s/\\end\{tabular\}[ \n]*//;
			$table =~ s/\\mybeginframe[ \n]*//;
			$table =~ s/\\myendframe[ \n]*//;

			close_paragraph ();

			$table_num = $table_num+1;
			my $the_num = get_table_number ();
			print $out "<diffyqshr/><table xml:id=\"$theid\" number=\"$the_num\">\n";
			print $out "  <title>$caption</title>\n";
			print $out "  <tabular top=\"major\" halign=\"$tablealign\">\n";

			if ($table =~ s/^(.*?)[ \n]*\\\\(\[.*?\])?[ \n]*//s) {
				$fline = $1;
				#FIXME: add spacing, though this should really be fixed in PreTeXt
				$fline =~ s|[ \n]*\&amp;[ \n]*|<nbsp/></cell><cell><nbsp/>|g;
				$fline =~ s|\$(.*?)\$|<m>$1</m>|sg;
				print $out "    <row bottom=\"minor\"><cell>$fline</cell></row>\n";
			} else {
				print "\n\n\nHUH?\n\n\nNo first line!\n\n$para\n\n";
				$num_errors++;
			}
			print $out "    <row><cell>";

			# kill trailing line end
			$table =~ s|[ \n]*\\\\(\[.*?\])?[ \n]*$||;

			$table =~ s|\$(.*?)\$|<m>$1</m>|sg;

			#FIXME: add spacing, though this should really be fixed in PreTeXt
			$table =~ s|[ \n]*\&amp;[ \n]*|<nbsp/></cell><cell><nbsp/>|g;
			$table =~ s|[ \n]*\\\\(\[.*?\])?[ \n]*|</cell></row>\n    <row><cell>|g;

			# last row should have bottom minor
			$table =~ s|<row>(.*?)$|<row bottom=\"minor\">$1|;

			print $out "$table</cell></row>\n  </tabular>\n</table><diffyqshr/>\n";
		} else {
			print "\n\n\nHUH?\n\n\nNo end table!\n\n$para\n\n";
			$num_errors++;
		}
		#
	#FIXME: not all substitutions are made, so check if more processing needs to be done
	#on contents and/or caption
	} elsif ($para =~ s/^(\\begin\{center\}[ \n]*)?\\begin\{tabular\}(.*)[ \n]*//) {
		my $centering = $1;
		my $tabulardef = $2;
		print "(TABULARONLY)\n";
		my $docenter = 0;
		if ($centering =~ m/^\\begin\{center\}/) {
			$docenter = 1;
		}

		my $tablealign = "left";
		if ($tabulardef =~ m/r/) {
			$tablealign = "right";
			if ($tabulardef =~ m/l/) {
				print "\n\n\nHUH?\n\n\nBoth left/right alignments in a table\n\n$para\n\n";
				$num_errors++;
			}
		}
		if ($tabulardef =~ m/c/) {
			print "\n\n\nHUH?\n\n\nCenter alignment in a table not allowed yet\n\n$para\n\n";
			$num_errors++;
		}

		if ($para =~ s/^(.*?)\\end\{tabular\}[ \n]*(\\end\{center\}[ \n]*)?//s) {
			my $table = $1;

			# FIXME possibly not ok within math?
			$table =~ s|~|<nbsp/>|g;

			# kill the rules 
			$table =~ s/\\capstart[ \n]*//g;
			my $dorules = 0;
			if ($table =~ s/\\(mid|bottom|top)rule[ \n]*//g) {
				$dorules = 1;
			}

			if ($docenter && $inparagraph == 0) {
				#FIXME: this doesn't work!
				#print $out "<p halign=\"center\">\n";
				print $out "<p>\n";
			}
			if ($dorules) {
				print $out "<tabular top=\"major\" halign=\"$tablealign\">\n";
			} else {
				print $out "<tabular halign=\"$tablealign\">\n";
			}

			if ($dorules) {
				if ($table =~ s/^(.*?)[ \n]*\\\\(\[.*?\])?[ \n]*//s) {
					$fline = $1;
					#FIXME: add spacing, though this should really be fixed in PreTeXt
					$fline =~ s|[ \n]*\&amp;[ \n]*|<nbsp/></cell><cell><nbsp/>|g;
					$fline =~ s|\$(.*?)\$|<m>$1</m>|sg;
					print $out "  <row bottom=\"minor\"><cell>$fline</cell></row>\n";
				} else {
					print "\n\n\nHUH?\n\n\nNo first line!\n\n$para\n\n";
					$num_errors++;
				}
			}
			print $out "  <row><cell>";

			# kill trailing line end
			$table =~ s|[ \n]*\\\\(\[.*?\])?[ \n]*$||;

			$table =~ s|\$(.*?)\$|<m>$1</m>|sg;

			#FIXME: add spacing, though this should really be fixed in PreTeXt
			$table =~ s|[ \n]*\&amp;[ \n]*|<nbsp/></cell><cell><nbsp/>|g;
			$table =~ s|[ \n]*\\\\(\[.*?\])?[ \n]*|</cell></row>\n  <row><cell>|g;

			# last row should have bottom minor
			if ($dorules) {
				$table =~ s|<row>(.*?)$|<row bottom=\"minor\">$1|;
			}

			print $out "$table</cell></row>\n</tabular>\n";
			if ($docenter && $inparagraph == 0) {
				print $out "</p>\n";
			}
		} else {
			print "\n\n\nHUH?\n\n\nNo end tabular/center!\n\n$para\n\n";
			$num_errors++;
		}
		
	#FIXME:Assuming that mywrapfigsimp never has a caption
	#FIXME:Assuming that mywrapfigsimp is always just an inputpdft
	} elsif ($para =~ s/^\\begin\{mywrapfigsimp\}\{.*?\}\{(.*?)\}[ \n]*// ||
		 $para =~ s/^\\begin\{mywrapfigsimp\}\[.*?\]\{.*?\}\{(.*?)\}[ \n]*//) {
		$float = "right";
		my $thesize = $1;
		print "(DIFFYFLOATINGFIGURE)\n";
		if ($para =~ s/^(.*?)\\end\{mywrapfigsimp\}[ \n]*//s) {
			my $fig = $1;

			# kill unneccesaray things
			$fig =~ s/\\\\[ \n]*//g;
			$fig =~ s/\\noindent[ \n]*//g;
			$fig =~ s/\\bigskip[ \n]*//g;
			$fig =~ s/\\medskip[ \n]*//g;
			$fig =~ s/\\diffypdfversion\{.*?\{.*?\}\}[ \n]*//g;
			$fig =~ s/\\diffypdfversion\{.*?\}[ \n]*//g;

			# FIXME: the above needs to cleaned up, the diffypdfversion macro is not a clean way to handle this I think

			if ($fig =~ m/^[ \n]*\\inputpdft\{(.*?)\}[ \n]*$/) {
				$thefile = "figures/$1";
				$thesizestr = get_size_of_svg("$thefile-tex4ht.svg");
				open_paragraph ();
				if ($thesizestr ne "") {
					print $out "<diffyqsimage source=\"$thefile-tex4ht\" $thesizestr float=\"$float\" />\n";
				} else {
					print $out "<diffyqsimage source=\"$thefile-tex4ht\" width=\"$thesize\" float=\"$float\" />\n";
				}
				close_paragraph ();
			} else {
				print "\n\n\nHUH?\n\n\nmywrapfigsimp not just an inputpdft!\n\nFIG=>$fig<\n\n";
				$num_errors++;
			}
		} else {
			print "\n\n\nHUH?\n\n\nNo end mywrapfigsimp\n\n$para\n\n";
			$num_errors++;
		}

	#FIXME: this is based entirely too much on my usage :)
	} elsif ($para =~ s/^\\begin\{center\}[ \n]*\\inputpdft\{(.*?)\}[ \n]*\\end\{center\}[ \n]*//) {
		my $thefile = "figures/$1";
		print "(CENTERED inputpdft)\n";
		#open_paragraph ();
		my $thesizestr = get_size_of_svg("$thefile-tex4ht.svg");
		open_paragraph ();
		if ($thesizestr ne "") {
			print $out "<diffyqsimage source=\"$thefile-tex4ht\" $thesizestr />\n";
		} else {
			#FIXME
			print "\n\n\nHUH?\n\n\nCan't figure out the size of $thefile\n\n";
			$num_errors++;
			print $out "<diffyqsimage source=\"$thefile-tex4ht\" height=\"1in\" />\n";
		}
		close_paragraph ();
		#
	#FIXME: this is based entirely too much on my usage :)
	} elsif ($para =~ s/^\\\\[ \n]*\\includegraphics\[width=(.*?)\]\{(.*?)\}[ \n]*\\\\[ \n]*//) {
		my $width = $1;
		my $thefile = $2;
		print "(BRed image >$width< >$thefile<\n)";
		ensure_mbx_svg_version ($thefile);
		#ensure_mbx_png_version ($thefile);
		open_paragraph ();
		print $out "<diffyqsimage source=\"$thefile-mbx\" width=\"$width\" background-color=\"white\" inline=\"yes\" />\n";
		close_paragraph ();

	#FIXME: this is based entirely too much on my usage :)
	} elsif ($para =~ s/^\\parbox\[c\]\{.*?\}\{\\includegraphics\[width=(.*?)\]\{(.*?)\}\}[ \n]*//) {
		my $width = $1;
		my $thefile = $2;
		print "(PARBOXED image >$width< >$thefile<\n)";
		ensure_mbx_svg_version ($thefile);
		#ensure_mbx_png_version ($thefile);
		print $out "<diffyqsimage source=\"$thefile-mbx\" width=\"$width\" background-color=\"white\" inline=\"yes\" />\n";
		
	#FIXME: this is based entirely too much on my usage :)
	} elsif ($para =~ s/^\\includegraphics\[width=(.*?)\]\{(.*?)\}[ \n]*//) {
		my $width = $1;
		my $thefile = $2;
		print "(Just inlined image >$width< >$thefile<\n)";
		ensure_mbx_svg_version ($thefile);
		#ensure_mbx_png_version ($thefile);
		print $out "<diffyqsimage source=\"$thefile-mbx\" width=\"$width\" background-color=\"white\" inline=\"yes\" />\n";

	#FIXME: not all substitutions are made, so check if more processing needs to be done
	#on caption
	} elsif ($para =~ s/^\\begin\{figure\}(\[.*?\])?[ \n]*// ||
	         $para =~ s/^\\begin\{mywrapfig\}(\[.*?\])?\{.*?\}[ \n]*// ||
	         $para =~ s/^\\begin\{myfig\}[ \n]*//) {
		print "(FIGURE)\n";
		if ($para =~ s/^(.*?)\\end\{figure\}[ \n]*//s ||
		    $para =~ s/^(.*?)\\end\{mywrapfig\}[ \n]*//s ||
		    $para =~ s/^(.*?)\\end\{myfig\}[ \n]*//s) {
			my $figure = $1;

			#print "FIGFIG >$figure<\n";
			
			$figure =~ s/\\begin\{center\}[ \n]*//g;
			$figure =~ s/\\end\{center\}[ \n]*//g;
			$figure =~ s/\\capstart[ \n]*//g;
			$figure =~ s/\\noindent[ \n]*//g;
			$figure =~ s/\\diffypdfversion\{.*?\{.*?\}\}[ \n]*//g;
			$figure =~ s/\\diffypdfversion\{.*?\}[ \n]*//g;
			
			# FIXME: the above needs to cleaned up, the diffypdfversion macro is not a clean way to handle this I think

			my @figs = ();

			#print "FIGFIG2 >$figure<\n";

			#FIXME: this is really my own particular usage!
			if ($figure =~ m/\\parbox/) {
				$foundsome = 0;
				print "found figure boxes\n";
				while ($figure =~ s/\\parbox\[t\]\{(.*?)\}\{(.*?)\n *\}//sm) {
					#print "FIGI >$1< >$2<\n";
					push @figs, $2;
					$foundsome = 1;
					print "got figure\n";
				}
				if (not $foundsome) {
					print "\n\n\nHUH?\n\n\nNo figure parboxes!\n\nFIG=$figure";
					$num_errors++;
				}
				if ($figure =~ m/\\parbox/) {
					print "\n\n\nHUH?\n\n\nFigure parboxes left over!\n\nFIG=$figure";
					$num_errors++;
				}
			} else {
				@figs = ($figure);
			}

			#print @figs;

			foreach (@figs) {
				my $fig = $_;

				#print "FIGFIG3 >$fig<\n";
				
				my $caption = "";
				my $theid = "";
				if ($fig =~ s/\\caption(\[.*?\])?\{(.*?)[ \n]*\\label\{(.*?)\}\}[ \n]*//s) {
					$caption = $2;
					$theid = modify_id($3);

					print "figure id $theid\n";
			
					# FIXME possibly not ok within math?
					$caption =~ s|~|<nbsp/>|g;
			
					$caption =~ s|\$(.*?)\$|<m>$1</m>|sg;

					$caption = do_ref_subs($caption);
				} else {
					print "\n\n\nHUH?\n\n\nNo caption/label!\n\nFIG=>$fig<\n\n";
					$num_errors++;
				}

				close_paragraph ();
				$fig =~ s/\\quad[ \n]*//g;
				$fig =~ s/\\qquad[ \n]*//g;
				$fig =~ s/\\(med|big|small)skip[ \n]*//g;
				$fig =~ s/\\par[ \n]*//g;

				$figure_num = $figure_num+1;
				$the_num = get_figure_number ();
				print $out "<diffyqshr/><figure xml:id=\"$theid\" number=\"$the_num\">\n";
				print $out "  <caption>$caption</caption>\n";

				if ($fig =~ m/^[ \n]*\\diffyincludegraphics\{[^}]*?\}\{([^}]*?)\}\{([^}]*?)\}[ \n]*$/) {
					my $thesize = $1;
					my $thefile = "figures/$2";
					$thesize =~ s/width=//g;
					ensure_mbx_svg_version ($thefile);
					#ensure_mbx_png_version ($thefile);
					print $out "  <diffyqsimage source=\"$thefile-mbx\" width=\"100\%\" background-color=\"white\" maxwidth=\"$thesize\" />\n";
					#if ($thesize ne "") {
					#print $out "  <diffyqsimage source=\"$thefile-mbx\" width=\"$thesize\" />\n";
					#} else {
					#$thesizestr = get_size_of_svg("$thefile-mbx.svg");
					#print $out "  <diffyqsimage source=\"$thefile-mbx\" $thesizestr />\n";
					#}
				} elsif ($fig =~ m/^[ \n]*\\diffyincludegraphics\{[^}]*?\}\{([^}]*?)\}\{([^}]*?)\}[ \n]*\\\\(\[[0-9]*pt\])?[ \n]*\\diffyincludegraphics\{[^}]*?\}\{([^}]*?)\}\{([^}]*?)\}[ \n]*$/) {
					my $thesize1 = $1;
					my $thefile1 = "figures/$2";
					my $thesize2 = $4;
					my $thefile2 = "figures/$5";
					$thesize1 =~ s/width=//g;
					$thesize2 =~ s/width=//g;
					ensure_mbx_svg_version ($thefile1);
					ensure_mbx_svg_version ($thefile2);
					#ensure_mbx_png_version ($thefile1);
					#ensure_mbx_png_version ($thefile2);
					#FIXME: what about maxwidth?
					print $out "  <diffyqsimage source=\"$thefile1-mbx\" width=\"100\%\" background-color=\"white\" maxwidth=\"$thesize1\" />\n";
					print $out "  <diffyqsimage source=\"$thefile2-mbx\" width=\"100\%\" background-color=\"white\" maxwidth=\"$thesize2\" />\n";

				#2 picture version FIXME: removing these, adding hand-done guys
				#} elsif ($fig =~ m/^[ \n]*\\diffyincludegraphics\{[^}]*?\}\{[^}]*?\}\{([^}]*?)}[ \n]*\\diffyincludegraphics\{[^}]*?\}\{[^}]*?\}\{([^}]*?)\}[ \n]*$/) {
				#$thefile1 = "figures/$1";
				#$thefile2 = "figures/$2";
				#print "DOUBLEFIGURE!\n"
				#ensure_mbx_svg_version ($thefile1);
				#ensure_mbx_svg_version ($thefile2);
				#print $out "<sidebyside xml:id=\"$theid\">\n";
				#print $out "  <caption>$caption</caption>\n";
				#print $out "  <figure>\n";
				#print $out "    <image source=\"$thefile1\" />\n";
				#print $out "  </figure>\n";
				#print $out "  <figure>\n";
				#print $out "    <image source=\"$thefile2\" />\n";
				#print $out "  </figure>\n";
				#print $out "</sidebyside>\n";
					#if ($thesize1 ne "") {
					#print $out "  <diffyqsimage source=\"$thefile1\" width=\"$thesize1\" />\n";
					#} else {
					#$thesizestr = get_size_of_svg("$thefile1.svg");
					#print $out "  <diffyqsimage source=\"$thefile1\" $thesizestr />\n";
					#}
					#if ($thesize2 ne "") {
					#print $out "  <diffyqsimage source=\"$thefile2\" width=\"$thesize2\" />\n";
					#} else {
					#$thesizestr = get_size_of_svg("$thefile2.svg");
					#print $out "  <diffyqsimage source=\"$thefile2\" $thesizestr />\n";
					#}
				#4 picture version FIXME: removing these, adding hand-done guys
				#} elsif ($fig =~ m/^[ \n]*\\diffyincludegraphics\{[^}]*?\}\{[^}]*?\}\{([^}]*?)\}[ \n]*\\diffyincludegraphics\{[^}]*?\}\{[^}]*?\}\{([^}]*?)\}[ \n]*\\diffyincludegraphics\{[^}]*?\}\{[^}]*?\}\{([^}]*?)\}[ \n]*\\diffyincludegraphics\{[^}]*?\}\{[^}]*?\}\{([^}]*?)}[ \n]*$/) {
				#$thefile1 = "figures/$1";
				#$thefile2 = "figures/$2";
				#$thefile3 = "figures/$3";
				#$thefile4 = "figures/$4";
				#print "QUADFIGURE!\n"
				#ensure_svg_version ($thefile1);
				#ensure_svg_version ($thefile2);
				#ensure_svg_version ($thefile3);
				#ensure_svg_version ($thefile4);
				#print $out "<figure xml:id=\"$theid\">\n";
				#print $out "  <caption>$caption</caption>\n";
				#print $out "  <image source=\"$thefile1\" />\n";
				#print $out "  <image source=\"$thefile2\" />\n";
				#print $out "  <image source=\"$thefile3\" />\n";
				#print $out "  <image source=\"$thefile4\" />\n";
					#$thesizestr = get_size_of_svg("$thefile1.svg");
					#print $out "  <diffyqsimage source=\"$thefile1\" $thesizestr />\n";
					#$thesizestr = get_size_of_svg("$thefile2.svg");
					#print $out "  <diffyqsimage source=\"$thefile2\" $thesizestr />\n";
					#$thesizestr = get_size_of_svg("$thefile3.svg");
					#print $out "  <diffyqsimage source=\"$thefile3\" $thesizestr />\n";
					#$thesizestr = get_size_of_svg("$thefile4.svg");
					#print $out "  <diffyqsimage source=\"$thefile4\" $thesizestr />\n";
					#print $out "</figure>\n";
				} elsif ($fig =~ m/^[ \n]*\\inputpdft\{(.*?)\}[ \n]*$/) {
					my $thefile = "figures/$1";
					my $thesizestr = get_size_of_svg("$thefile-tex4ht.svg");
					print $out "<diffyqsimage source=\"$thefile-tex4ht\" $thesizestr />\n";
				} else {
					print "\n\n\nHUH?\n\n\nFigure too complicated!\n\nFIG=>$fig<\n\n";
					$num_errors++;
				}
				print $out "</figure><diffyqshr/>\n";

			}
		} else {
			print "\n\n\nHUH?\n\n\nNo end figure!\n\n$para\n\n";
			$num_errors++;
		}

	} elsif ($para =~ s/^\\begin\{theorem\}[ \n]*//) {
		close_paragraph();
		my $title = "";
		my $footnote = "";
		if ($para =~ s/^\[(.*?)\][ \n]*//s) {
			$title = do_thmtitle_subs($1);
			# FIXME: hack, this is only because pretext html
			# backend does not deal well with footnotes in
			# theorem titles.
			# FIXME: should check if it really works with
			# multiple footnotes
			while ($title =~ s|(\<fn\>.*?\</fn\>)||s) {
				$footnote = $footnote . $1;
			}
		}

		$thm_num = $thm_num+1;
		$the_num = get_thm_number ();

		my $theid = "";
		if ($para =~ s/^[ \n]*\\label\{(.*?)\}[ \n]*//s) {
			$theid = modify_id($1);
		}

		#FIXME: hack because I sometime switch index and label
		my $indexo = "";
		while ($para =~ s/^[ \n]*\\index\{(.*?)\}[ \n]*//s) {
			$term = do_line_subs($1);
			$term =~ s|^(.*)!(.*)$|<h>$1</h><h>$2</h>|s;
			$term =~ s|\$(.*?)\$|<m>$1</m>|sg;
			$indexo = $indexo . "<idx>$term</idx>\n";
		}

		#FIXME: hack because I sometime switch index and label
		if ($para =~ s/^[ \n]*\\label\{(.*?)\}[ \n]*//s) {
			$theid = modify_id($1);
		}

		if ($theid ne "") {
			print $out "<theorem xml:id=\"$theid\" number=\"$the_num\">\n";
		} else {
			print $out "<theorem number=\"$the_num\">\n";
		}
		if ($title ne "") {
			print $out "<title>$title</title>\n";
		}
		if ($indexo ne "") {
			print $out "$indexo\n";
		}
		print $out "<statement>\n";

		open_paragraph();

		if ($footnote ne "") {
			print $out "$footnote\n";
		}

	} elsif ($para =~ s/^\\end\{theorem\}[ \n]*//) {
		close_paragraph();
		print $out "</statement>\n</theorem>\n";



	} elsif ($para =~ s/^\\begin\{exercise\}\[(easy|challenging|tricky|computer project|project|little harder|harder|more challenging)\][ \n]*//) {
		my $note = $1;
		close_paragraph();
		$exercise_num = $exercise_num+1;
		my $the_num = get_exercise_number ();
		if ($para =~ s/^\\label\{([^}]*)\}[ \n]*//) {
			$theid = modify_id($1);
			print "(exercise start note >$note< id >$theid< $the_num)\n";
			print $out "<exercise xml:id=\"$theid\" number=\"$the_num\">\n<statement>\n";
		} else {
			print "(exercise start note >$note< $the_num)\n";
			print $out "<exercise number=\"$the_num\">\n<statement>\n";
		}

		open_paragraph();
		print $out "<em>($note)</em><nbsp/><nbsp/>\n";

	} elsif ($para =~ s/^\\begin\{exercise\}\[(.*?)\][ \n]*//s) {
		my $title = $1;
		$title =~ s|\$(.*?)\$|<m>$1</m>|sg;
		my $index = "";
		if ($title =~ s/\\myindex\{(.*?)\}/$1/) {
			$index = do_line_subs($1);
		}
		close_paragraph();
		$exercise_num = $exercise_num+1;
		my $the_num = get_exercise_number ();
		if ($para =~ s/^\\label\{([^}]*)\}[ \n]*//) {
			$theid = modify_id($1);
			print "(exercise start title >$title< id >$theid< $the_num)\n";
			print $out "<exercise xml:id=\"$theid\" number=\"$the_num\">\n";
			print $out "<title>$title</title>\n";
		} else {
			print "(exercise start title >$title< $the_num)\n";
			print $out "<exercise number=\"$the_num\">\n";
			print $out "<title>$title</title>\n";
		}
		if ($index ne "") {
			print $out "<idx>$index</idx>\n";
		}
		print $out "<statement>\n";
		open_paragraph();


	} elsif ($para =~ s/^\\begin\{exercise\}[ \n]*\\begin\{samepage\}[ \n]*// ||
		$para =~ s/^\\begin\{exercise\}[ \n]*//) {
		close_paragraph();
		$exercise_num = $exercise_num+1;
		my $the_num = get_exercise_number ();
		if ($para =~ s/^\\label\{([^}]*)\}[ \n]*//) {
			$theid = modify_id($1);
			print "(exercise start >$theid< $the_num)\n";
			print $out "<exercise xml:id=\"$theid\" number=\"$the_num\">\n";
			print $out "<statement>\n";
		} else {
			print "(exercise start $the_num)\n";
			print $out "<exercise number=\"$the_num\">\n";
			print $out "<statement>\n";
		}
		open_paragraph();

	} elsif ($para =~ s/^\\end\{exercise\}[ \n]*\\exsol\{// ||
	         $para =~ s/^\\end\{samepage\}[ \n]*\\end\{exercise\}[ \n]*\\exsol\{// ||
	         $para =~ s/^\\end\{exercise\}[ \n]*\\end\{samepage\}[ \n]*\\exsol\{//) {
		print "(exercise end)\n";
		print "(exsol start)\n";
		close_paragraph();
		print $out "</statement>\n<answer>\n"; 
		push @cltags, "exsol";
	} elsif ($para =~ s/^\\end\{exercise\}[ \n]*//) {
		print "(exercise end)\n";
		close_paragraph();
		print $out "</statement>\n</exercise>\n";

	} elsif ($para =~ s/^\\begin\{center\}[ \n]*//) {
		#FIXME: no centering yet
		open_paragraph();
		print "(begin center)";

	} elsif ($para =~ s/^\\end\{center\}[ \n]*//) {
		#FIXME: no centering yet
		close_paragraph();
		print "(end center)";

	} elsif ($para =~ s/^\\begin\{example\}[ \n]*//) {
		close_paragraph();
		$example_num = $example_num+1;
		my $the_num = get_example_number ();
		if ($para =~ s/^\\label\{([^}]*)\}[ \n]*//) {
			$theid = modify_id($1);
			print "(example start >$theid<)\n";
			print $out "<example xml:id=\"$theid\" number=\"$the_num\">\n";
			print $out "<statement>\n";
		} else {
			print "(example start)\n";
			print $out "<example number=\"$the_num\">\n";
			print $out "<statement>\n";
		}
		open_paragraph();
	} elsif ($para =~ s/^\\end\{example\}[ \n]*//) {
		close_paragraph();
		print $out "</statement>\n</example>\n";

	} elsif ($para =~ s/^\\begin\{remark\}[ \n]*//) {
		close_paragraph();
		$remark_num = $remark_num+1;
		my $the_num = get_remark_number ();
		if ($para =~ s/^\\label\{([^}]*)\}[ \n]*//) {
			$theid = modify_id($1);
			print "(remark start >$theid<)\n";
			print $out "<remark xml:id=\"$theid\" number=\"$the_num\">\n";
			print $out "<statement>\n";
		} else {
			print "(remark start)\n";
			print $out "<remark number=\"$the_num\">\n";
			print $out "<statement>\n";
		}
		open_paragraph();
	} elsif ($para =~ s/^\\end\{remark\}[ \n]*//) {
		close_paragraph();
		print $out "</statement>\n</remark>\n";

	} elsif ($para =~ s/^\\begin\{itemize\}[ \n]*//) {
		close_paragraph();
		print "(begin itemize)\n";
		print $out "<ul>\n";
	} elsif ($para =~ s/^\\end\{itemize\}[ \n]*//) {
		close_item();
		print $out "</ul>\n";

	} elsif ($para =~ s/^\\begin\{enumerate\}\[(.*?),resume\][ \n]*//) {
		close_paragraph();
		print "(begin enumerate resume label >$1<)\n";
		if ($list_level > 0) {
			print "\n\n\nHUH? RESUME ONLY WORKS ON ONE LEVEL!\n\n\n";
			$num_errors++;
		}
		print $out "<ol marker=\"$1\" start=\"$list_start\">\n";
		$list_level++;
	} elsif ($para =~ s/^\\begin\{enumerate\}\[resume\][ \n]*//) {
		close_paragraph();
		print "(begin enumerate resume)\n";
		if ($list_level > 0) {
			print "\n\n\nHUH? RESUME ONLY WORKS ON ONE LEVEL!\n\n\n";
			$num_errors++;
		}
		print $out "<ol start=\"$list_start\">\n";
		$list_level++;
	} elsif ($para =~ s/^\\begin\{enumerate\}\[(.*?)\][ \n]*//) {
		close_paragraph();
		print "(begin enumerate label >$1<)\n";
		print $out "<ol marker=\"$1\">\n";
		$list_start=1;
		$list_level++;
	} elsif ($para =~ s/^\\begin\{enumerate\}[ \n]*//) {
		close_paragraph();
		print "(begin enumerate)\n";
		print $out "<ol>\n";
		$list_start=1;
		$list_level++;
	} elsif ($para =~ s/^\\end\{enumerate\}[ \n]*//) {
		close_item();
		print $out "</ol>\n";
		$list_level--;

	} elsif ($para =~ s/^\\item[ \n]*//) {
		print "(item)\n";
		$list_start++;
		open_item();
		open_paragraph();

	} elsif ($para =~ s/^\\begin\{tasks\}\[counter-format=tsk\[1\]\)\][ \n]*// ||
		 $para =~ s/^\\begin\{tasks\}\[label=\\arabic\*\)\][ \n]*//) {
		close_paragraph();
		print "(begin tasks enumerate label 1)<)\n";
		print $out "<ol marker=\"1)\">\n";
		$list_start=1;
		$list_level++;
	} elsif ($para =~ s/^\\begin\{tasks\}\[counter-format=tsk\[1\]\)\]\((.*?)\)[ \n]*// ||
		 $para =~ s/^\\begin\{tasks\}\[label=\\arabic\*\)\]\((.*?)\)[ \n]*//) {
		close_paragraph();
		print "(begin tasks enumerate label 1) cols=$1<)\n";
		print $out "<ol marker=\"1)\" cols=\"$1\">\n";
		$list_start=1;
		$list_level++;
	} elsif ($para =~ s/^\\begin\{tasks\}\[resume\]\((.*?)\)[ \n]*//) {
		close_paragraph();
		#FIXME: double check that this really works
		#print "\n\n\nHUH? Don't understand resume on tasks yet!\n\n\n";
		#$num_errors++;
		print "(begin resume tasks enumerate cols=$1<)\n";
		if ($list_level > 0) {
			print "\n\n\nHUH? RESUME ONLY WORKS ON ONE LEVEL!\n\n\n";
			$num_errors++;
		}
		print $out "<ol marker=\"a)\" cols=\"$1\" start=\"$list_start\">\n";
		$list_level++;
	} elsif ($para =~ s/^\\begin\{tasks\}\[resume\][ \n]*//) {
		close_paragraph();
		#FIXME: DOUBLE CHECK
		#print "\n\n\nHUH? Don't understand resume on tasks yet!\n\n\n";
		#$num_errors++;
		print "(begin resume tasks enumerate)\n";
		if ($list_level > 0) {
			print "\n\n\nHUH? RESUME ONLY WORKS ON ONE LEVEL!\n\n\n";
			$num_errors++;
		}
		print $out "<ol marker=\"a)\" start=\"$list_start\">\n";
		$list_level++;
	} elsif ($para =~ s/^\\begin\{tasks\}\((.*?)\)[ \n]*//) {
		close_paragraph();
		print "(begin tasks enumerate cols=$1<)\n";
		print $out "<ol marker=\"a)\" cols=\"$1\">\n";
		$list_start=1;
		$list_level++;
	} elsif ($para =~ s/^\\begin\{tasks\}[ \n]*//) {
		close_paragraph();
		print "(begin tasks enumerate)\n";
		print $out "<ol marker=\"a)\">\n";
		$list_start=1;
		$list_level++;
	} elsif ($para =~ s/^\\end\{tasks\}[ \n]*//) {
		close_item();
		print $out "</ol>\n";
		$list_level--;

	} elsif ($para =~ s/^\\task\*?[ \n]*//) {
		print "(task)\n";
		$list_start++;
		open_item();
		open_paragraph();

	} elsif ($para =~ s/^([^\$\\{]*?)\}//) {
		my $line = $1;
		my $tagtoclose = pop @cltags;
		print "closing tag ($tagtoclose) after >$line<\n\n";
		print_line($line);
		if ($tagtoclose eq "em") {
			print $out "</em>";
		} elsif ($tagtoclose eq "myquote") {
			print $out "</q>";
		} elsif ($tagtoclose eq "exsol") {
			print "(exsol end)\n";
			close_paragraph ();
			print $out "</answer>\n</exercise>\n";
		} elsif ($tagtoclose eq "footnote") {
			#FIXME: nested paragraphs??  Does this work?
			print $out "</fn>";
		} else {
			print "\n\nHUH???\n\nNo (or unknown =\"$tagtoclose\") tag to close\n\n";
			$num_errors++;
		}


	} elsif ($para =~ s/^\\[cl]?dots\b//) {
		open_paragraph_if_not_open ();
		print $out "...";
		print "...\n";

	} elsif ($para =~ s/^\\appendix\b//) {
		print "(start appendices)\n";
		close_chapter();
		$in_appendix = 1;
		$chapter_num = 0;

	} elsif ($para =~ s/^\\leavevmode\b//) {
		print "(leavevmode do nothing)\n";

	} elsif ($para =~ s/^\\noindent\b//) {
		print "(noindent do nothing)\n";
	} elsif ($para =~ s/^\\sectionnewpage\b//) {
		print "(sectionnewpage do nothing)\n";
	} elsif ($para =~ s/^\\nopagebreak(\[.\])?//) {
		print "(nopagebreak do nothing)\n";
	} elsif ($para =~ s/^\\pagebreak(\[.\])?//) {
		print "(pagebreak do nothing)\n";
	} elsif ($para =~ s/^\\linebreak(\[.\])?//) {
		print "(linebreak do nothing)\n";

	} elsif ($para =~ s/^\\ //) {
		print "( )\n";
		print $out " "; 
	} elsif ($para =~ s/^\\-//) {
		print "(-)\n";
		open_paragraph_if_not_open ();
		print $out "-"; 
	} elsif ($para =~ s/^\\medskip\b *//) {
		print "(medskip)\n";
		if ($inparagraph) {
			#print $out "</p><p><nbsp/></p><p><!--FIXME:this seems an ugly solution-->\n"; 
			print $out "</p><p><!--FIXME:this seems an ugly solution-->\n"; 
			
			# already skipping some space if not in paragraph?
			#} else {
			#print $out "<p><nbsp/></p><!--FIXME:this seems an ugly solution-->\n"; 
		}
	} elsif ($para =~ s/^\\bigskip *//) {
		print "(bigskip)\n";
		if ($inparagraph) {
			#print $out "</p><p><nbsp/></p><p><!--FIXME:this seems an ugly solution-->\n"; 
			print $out "</p><p><!--FIXME:this seems an ugly solution-->\n"; 

			# already skipping some space if not in paragraph?
			#} else {
			#print $out "<p><nbsp/></p><!--FIXME:this seems an ugly solution-->\n"; 
		}
	} elsif ($para =~ s/^\\\\\[[0-9a-z]*\]// ||
		 $para =~ s/^\\\\//) {
		print "(BR)\n";
		if ($inparagraph) {
			#print $out "</p><p><!--FIXME:this seems an ugly solution-->"; 
			print $out "<diffyqsbr/>";
		}
		#FIXME: What to do if not in paragraph?  Is that even reasonable?
	} elsif ($para =~ s/^\\enspace//) {
		print "(enspace)\n";
		open_paragraph_if_not_open ();
		print $out "<nbsp/><nbsp/>"; 
	} elsif ($para =~ s/^\\quad//) {
		print "(quad)\n";
		open_paragraph_if_not_open ();
		print $out "<nbsp/><nbsp/><nbsp/>"; 
	} elsif ($para =~ s/^\\qquad//) {
		print "(qquad)\n";
		open_paragraph_if_not_open ();
		print $out "<nbsp/><nbsp/><nbsp/><nbsp/><nbsp/><nbsp/>"; 
	} elsif ($para =~ s/^\\LaTeX//) {
		print "(LaTeX)\n";
		open_paragraph_if_not_open ();
		print $out "<latex />"; 

	} elsif ($para =~ s/^\\footnote\{//) {
		print "(FOOTNOTE start)\n";
		open_paragraph_if_not_open ();
		print $out "<fn>"; 
		push @cltags, "footnote";

	} elsif ($para =~ s/^\\begin\{samepage\}[ \n]*//) {
		print "(begin samepage} do nothing)\n";

	} elsif ($para =~ s/^\\end\{samepage\}[ \n]*//) {
		print "(end{samepage} do nothing)\n";

	} elsif ($para =~ s/^\\begin\{mysamepage\}[ \n]*//) {
		print "(begin mysamepage} do nothing)\n";

	} elsif ($para =~ s/^\\end\{mysamepage\}[ \n]*//) {
		print "(end{mysamepage} do nothing)\n";

	} elsif ($para =~ s/^\\@//) {
		print "(\\@ do nothing)\n";

	} elsif ($para =~ s/^([^\\]+?)\$/\$/) {
		my $line = $1;
		print_line($line);
	} elsif ($para =~ s/^([^\\]+?)\\/\\/) {
		my $line = $1;
		print_line($line);
	} elsif ($para =~ s/^(\\[^ \n\r\t{]*)//) {
		print "\n\nHUH???\n\nUNHANDLED escape $1!\n$para\n\n";
		print_line($1);
		#$para = "";
		$num_errors++;
	} else {
		print_line($para);
		$para = "";
	}
	if ($para eq "") {
		close_paragraph ();
	}
}

close_chapter ();

print $out <<END;
</book>
</pretext>
END

close ($in); 
close ($out); 
 
print "\nDone! (number of errors $num_errors)\n"; 
