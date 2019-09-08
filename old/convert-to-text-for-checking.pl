#!/usr/bin/perl
#
# Script to convert this particular LaTeX file to plain text, but removing
# a lot of stuff.  Useful for language checking.
#
# FIXME: this is just a quick hack of the mbx conversion script, it is probably
# too complicated for its own good.
#
print "running ...\n"; 

$num_errors = 0;

my @ins;
 
open(my $in,'<', "diffyqs.tex") or die $!; 
open(my $out, '>' ,"diffyqs-out.txt") or die $!; 
 
# No \input file reading here (FIXME?)
while($line = <$in>)
{
	chomp($line);
	if ($line =~ m/^\\begin\{document\}/) {
		printf ("found begin document\n");
		last;
	}
}

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

$exercise_num = 0;
$thm_num = 0;
$remark_num = 0;
$example_num = 0;

#FIXME: equation counter implement
$equation_num = 0;

print $out $commands;

sub close_paragraph {
	if ($inparagraph) {
		$inparagraph = 0;
		print $out "\n\n"
	}
}
sub close_item {
	close_paragraph ();
	if ($initem) {
		$initem = 0;
		print $out "\n"
	}
}
sub close_subsubsection {
	close_paragraph ();
	if ($insubsubsection == 2) {
		$insubsubsection = 0;
		print $out "\n\n"
	} elsif ($insubsubsection) {
		$insubsubsection = 0;
		print $out "\n\n"
	}
}
sub close_subsection {
	close_subsubsection ();
	if ($insubsection == 2) {
		$insubsection = 0;
		print $out "\n\n"
	} elsif ($insubsection) {
		$insubsection = 0;
		print $out "\n\n"
	}
}
sub close_section {
	close_subsection();
	if ($insection) {
		$insection = 0;
		print $out "\n\n"
	}
}
sub close_chapter {
	close_section ();
	if ($inchapter) {
		$inchapter = 0;
		print $out "\n\n"
	}
}
sub open_paragraph {
	close_paragraph ();
	$inparagraph = 1;
	print $out "\n\n"
}
sub open_paragraph_if_not_open {
	if ($inparagraph == 0) {
		$inparagraph = 1;
		print $out "\n\n"
	}
}
sub open_item {
	close_item ();
	$initem = 1;
	print $out "\n"
}
sub open_subsubsection {
	my $theid = shift;
	my $name = shift;
	close_subsubsection ();
	$insubsubsection = 1;
	$subsubsection_num = $subsubsection_num+1;

	print "(subsubsection >$name< label >$theid<)\n";
	print $out "$name\n"; 
}
sub open_intro_subsubsection {
	$insubsubsection = 2;

	print $out "\n\n";
}
sub open_subsection {
	my $theid = shift;
	my $name = shift;
	close_subsection ();
	$insubsection = 1;
	$subsection_num = $subsection_num+1;

	$subsubsection_num = 0;

	print "(subsection >$name< label >$theid<)\n";
	print $out "$name\n"; 

}
sub open_intro_subsection {
	$insubsection = 2;

	print $out "\n\n";
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

	print "(section >$name< label >$theid<)\n";
	print $out "$name\n"; 

	open_intro_subsection();
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

	if ($line =~ s|~| |g) {
		print "substituted nbsps\n";
	}
	if ($line =~ s|---|-|g) {
		print "substituted emdashes\n";
	}
	if ($line =~ s|--|-|g) {
		print "substituted endashes\n";
	}
	##FIXME: should we do this?
	#if ($line =~ s|-|&#x2010;|g) {
	#print "substituted hyphens\n";
	#}
	
	return $line;
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

	$title =~ s|\\href\{(.*?)\}\{(.*?)\}|$2|s;

	#FIXME: should check if multiple footnotes work
	while ($title =~ s|\\footnote\{(.*?)\}| ($1)|s) {
		;
	}

	$title = do_line_subs($title);

	return $title;
}

sub get_exercise_number {
	if ($insection) {
		return "$chapter_num.$section_num.$exercise_num";
	} elsif ($inchapter) {
		return "$chapter_num.$exercise_num";
	} else {
		return "$exercise_num";
	}
}

sub get_thm_number {
	if ($insection) {
		return "$chapter_num.$section_num.$thm_num";
	} elsif ($inchapter) {
		return "$chapter_num.$thm_num";
	} else {
		return "$thm_num";
	}
}

sub get_remark_number {
	if ($insection) {
		return "$chapter_num.$section_num.$remark_num";
	} elsif ($inchapter) {
		return "$chapter_num.$remark_num";
	} else {
		return "$remark_num";
	}
}

sub get_example_number {
	if ($insection) {
		return "$chapter_num.$section_num.$example_num";
	} elsif ($inchapter) {
		return "$chapter_num.$example_num";
	} else {
		return "$example_num";
	}
}

sub get_equation_number {
	return "$equation_num";
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

		if ( $line =~ m/^\\input[ \t][ \t]*(.*)$/) {
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
		} elsif ($line =~ m/^\\documentclass/ ||
			$line =~ m/^\\usepackage/ ||
			$line =~ m/^\\addcontentsline/) {
			# do nothing
			;
		} elsif ($line =~ m/^%mbxBACKMATTER/) {
			close_chapter ();
		} elsif ($line =~ m/^%mbxINTROSUBSUBSECTION/) {
			open_intro_subsubsection ();
		} else {
			my $newline = 1;
			if ($line =~ m/^%/ || $line =~ m/[^\\]%/) {
				$newline = 0;
			}
			$line =~ s/^%.*$//;
			$line =~ s/([^\\])%.*$/$1/;

			$line =~ s/  / /gs;

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

	#Do simple substitutions
	$para =~ s/\\"\{o\}/ö/g;
	$para =~ s/\\"o/ö/g;
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
	$para =~ s/\\'i/í/g;
	$para =~ s/\\'\{i\}/í/g;
	$para =~ s/\\'E/É/g;
	$para =~ s/\\'\{E\}/É/g;
	$para =~ s/\\S([^a-zA-Z])/§$1/g;

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
		print $out "X";

	} elsif ($para =~ s/^\\chapter\*\{([^}]*)\}[\n ]*\\label\{([^}]*)\}[ \n]*//) {
		#FIXME: un-numbered
		my $name = $1;
		my $theid = modify_id($2);
		$name =~ s|\$(.*?)\$|X|gs;
		$chapter_num = $chapter_num-1; #hack
		open_chapter($theid);
		print "(chapter >$name< label >$theid<)\n";
		print $out "$name\n"; 
		print "PARA:>$para<\n";
	} elsif ($para =~ s/^\\chapter\*\{([^}]*)\}[ \n]*//) {
		my $name = $1;
		#FIXME: un-numbered
		$chapter_num = $chapter_num-1; #hack
		$name =~ s|\$(.*?)\$|X|gs;
		open_chapter("");
		print "(chapter >$name<)\n";
		print $out "$name\n"; 
	} elsif ($para =~ s/^\\chapter\{([^}]*)\}[\n ]*\\label\{([^}]*)\}[ \n]*//) {
		my $name = $1;
		my $theid = modify_id($2);
		$name =~ s|\$(.*?)\$|X|gs;
		open_chapter($theid);
		print "(chapter >$name< label >$theid<)\n";
		print $out "$name\n"; 
	} elsif ($para =~ s/^\\chapter\{([^}]*)\}[ \n]*//) {
		my $name = 1;
		open_chapter("");
		$name =~ s|\$(.*?)\$|X|gs;
		print "(chapter >$name<)\n";
		print $out "$name\n"; 
	} elsif ($para =~ s/^\\section\{([^}]*)\}[ \n]*\\label\{([^}]*)\}[ \n]*//) {
		my $name = $1;
		my $theid = modify_id($2);
		$name =~ s|\$(.*?)\$|X|gs;
		open_section($theid,$name);
	} elsif ($para =~ s/^\\section\{([^}]*)\}[ \n]*//) {
		my $name = $1;
		my $theid = modify_id($2);
		$name =~ s|\$(.*?)\$|X|gs;
		open_section("",$name);
	} elsif ($para =~ s/^\\subsection\{([^}]*)\}[ \n]*\\label\{([^}]*)\}[ \n]*//) {
		my $name = $1;
		my $theid = modify_id($2);
		$name =~ s|\$(.*?)\$|X|gs;
		open_subsection($theid,$name);
	} elsif ($para =~ s/^\\subsection\{([^}]*)\}[ \n]*//) {
		my $name = $1;
		my $theid = modify_id($2);
		$name =~ s|\$(.*?)\$|X|gs;
		open_subsection("",$name);
	} elsif ($para =~ s/^\\subsubsection\{([^}]*)\}[ \n]*\\label\{([^}]*)\}[ \n]*//) {
		my $name = $1;
		my $theid = modify_id($2);
		$name =~ s|\$(.*?)\$|X|gs;
		open_subsubsection($theid,$name);
	} elsif ($para =~ s/^\\subsubsection\{([^}]*)\}[ \n]*//) {
		my $name = $1;
		my $theid = modify_id($2);
		$name =~ s|\$(.*?)\$|X|gs;
		open_subsubsection("",$name);

	# this assumes sectionnotes come in their own $para
	} elsif ($para =~ s/^\\sectionnotes\{(.*)\}[ \n\t]*//s) {
		my $secnotes = do_line_subs($1);
		$secnotes =~ s|\\cite\{([^}]*)\}|[0]|g;
		$secnotes =~ s|\\BDref\{([^}]*)\}|$1|g;
		$secnotes =~ s|\\EPref\{([^}]*)\}|$1|g;
		print "(secnotes $secnotes)\n";
		print "(cite $secnotes)\n";
		print $out "\nNote: $secnotes\n"; 

	} elsif ($para =~ s/^\\setcounter\{exercise\}\{(.*?)\}[ \n\t]*//s) {
		$exercise_num=$1;

	} elsif ($para =~ s/^\\href\{([^}]*)\}\{([^}]*)\}//) {
		open_paragraph_if_not_open ();
		print "(link $1 $2)\n";
		print $out "$2"; 
	} elsif ($para =~ s/^\\url\{([^}]*)\}//) {
		open_paragraph_if_not_open ();
		print "(url $1)\n";
		print $out "$1"; 
	} elsif ($para =~ s/^\\cite\{([^}]*)\}//) {
		open_paragraph_if_not_open ();
		print "(cite $1)\n";
		print $out "[0]"; 

	} elsif ($para =~ s/^\\index\{([^}]*)\}//) {
		open_paragraph_if_not_open ();
		print "(index $1)\n";
	} elsif ($para =~ s/^\\myindex\{([^}]*)\}//) {
		open_paragraph_if_not_open ();
		print "(myindex $1)\n";
		my $index = $1;
		$index =~ s|\$(.*?)\$|X|sg;
		print $out "$index"; 

	} elsif ($para =~ s/^\\eqref\{([^}]*)\}//) {
		open_paragraph_if_not_open ();
		my $theid = modify_id($1);
		print "(eqref $theid)\n";
		print $out "(0)";
	} elsif ($para =~ s/^\\ref\{([^}]*)\}//) {
		open_paragraph_if_not_open ();
		my $theid = modify_id($1);
		print "(ref $theid)\n";
		print $out "0";
	} elsif ($para =~ s/^\\chapterref\{([^}]*)\}// ||
		$para =~ s/^\\chaptervref\{([^}]*)\}// ||
		$para =~ s/^\\Chapterref\{([^}]*)\}// ||
		$para =~ s/^\\sectionref\{([^}]*)\}// ||
		$para =~ s/^\\sectionvref\{([^}]*)\}// ||
		$para =~ s/^\\thmref\{([^}]*)\}// ||
		$para =~ s/^\\thmvref\{([^}]*)\}// ||
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
		print $out "X";
	} elsif ($para =~ s/^\\hyperref\[([^[]*)\]\{([^}]*)\}//) {
		my $name = $2;
		my $theid = modify_id($1);
		open_paragraph_if_not_open ();
		print "(hyperref $theid $name)\n";
		print $out "$name";
	} elsif ($para =~ s/^\\emph\{//) {
		print "(em start)\n";
		open_paragraph_if_not_open();
		push @cltags, "em";
	} elsif ($para =~ s/^\\myquote\{//) {
		print "(myquote start)\n";
		open_paragraph_if_not_open();
		push @cltags, "myquote";
		print $out "\"";

	} elsif ($para =~ s/^\\textbf\{(.*?)\}//s) {
		print "(textbf $1)\n";
		open_paragraph_if_not_open ();
		print $out "$1";

	} elsif ($para =~ s/^\\texttt\{(.*?)\}//s) {
		print "(texttt $1)\n";
		open_paragraph_if_not_open ();
		print $out "$1"; 

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
		print $out "X"; 
	} elsif ($para =~ s/^\\unitfrac\[(.*?)\]\{(.*?)\}\{(.*?)\}//s) {
		my $txt = $1;
		my $unitnum = $2;
		my $unitden = $3;

		$txt =~ s|\$(.*?)\$|X|gs;
		print "(unitfrac $txt $unitnum/$unitden)\n";
		open_paragraph_if_not_open ();
		print $out "$txt X"; 

	} elsif ($para =~ s/^\\begin\{align\*\}[ \n]*//) {
		print "(ALIGN*)\n";
		if ($para =~ s/^(.*?)\\end\{align\*\}[ \n]*//s) {
			#FIXME: Is wrapping in aligned all kosher?
			print $out "\n\nX\n\n";
		} else {
			print "\n\n\nHUH?\n\n\nNo end align*!\n\n$para\n\n";
			$num_errors++;
		}
	} elsif ($para =~ s/^\\begin\{align\}[ \n]*//) {
		print "(ALIGN)\n";
		if ($para =~ s/^(.*?)\\end\{align\}[ \n]*//s) {
			print $out "\n\nX\n\n";
		} else {
			print "\n\n\nHUH?\n\n\nNo end align!\n\n$para\n\n";
			$num_errors++;
		}

	} elsif ($para =~ s/^\\begin\{multline\*\}[ \n]*//) {
		print "(MULTLINE*)\n";
		if ($para =~ s/^(.*?)\\end\{multline\*\}[ \n]*//s) {
			print $out "\n\nX\n\n";
		} else {
			print "\n\n\nHUH?\n\n\nNo end multline*!\n\n$para\n\n";
			$num_errors++;
		}
	} elsif ($para =~ s/^\\begin\{multline\}[ \n]*//) {
		print "(MULTLINE)\n";
		if ($para =~ s/^(.*?)\\end\{multline\}[ \n]*//s) {
			print $out "\n\nX\n\n";
		} else {
			print "\n\n\nHUH?\n\n\nNo end multline!\n\n$para\n\n";
			$num_errors++;
		}

	} elsif ($para =~ s/^\\begin\{equation\*\}[ \n]*//) {
		print "(EQUATION*)\n";
		if ($para =~ s/^(.*?)\\end\{equation\*\}[ \n]*//s) {
			print $out "\n\nX\n\n";
		} else {
			print "\n\n\nHUH?\n\n\nNo end equation*!\n\n$para\n\n";
			$num_errors++;
		}
	} elsif ($para =~ s/^\\begin\{equation\}[ \n]*//) {
		print "(EQUATION)\n";
		if ($para =~ s/^(.*?)\\end\{equation\}[ \n]*//s) {
			print $out "\n\nX\n\n";
		} else {
			print "\n\n\nHUH?\n\n\nNo end equation!\n\n$para\n\n";
			$num_errors++;
		}

	#FIXME: not all substitutions are made, so check if more processing needs to be done
	#on contents and/or caption
	} elsif ($para =~ s/^\\begin\{table\}(\[.*?\])?[ \n]*//) {
		print "(TABLE)\n";
		if ($para =~ s/^(.*?)\\end\{table\}[ \n]*//s) {
			print $out "\n\nX\n\n";
		} else {
			print "\n\n\nHUH?\n\n\nNo end table!\n\n$para\n\n";
			$num_errors++;
		}
		#
	#FIXME: not all substitutions are made, so check if more processing needs to be done
	#on contents and/or caption
	} elsif ($para =~ s/^(\\begin\{center\}[ \n]*)?\\begin\{tabular\}.*[ \n]*//) {
		print "(TABULARONLY)\n";
		my $docenter = 0;
		if ($1 =~ m/^\\begin\{center\}/) {
			$docenter = 1;
		}
		if ($para =~ s/^(.*?)\\end\{tabular\}[ \n]*(\\end\{center\}[ \n]*)?//s) {
			print $out "\n\nX\n\n";
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
			print $out "\n\nX\n\n";
		} else {
			print "\n\n\nHUH?\n\n\nNo end mywrapfigsimp\n\n$para\n\n";
			$num_errors++;
		}

	#FIXME: this is based entirely too much on my usage :)
	} elsif ($para =~ s/^\\begin\{center\}[ \n]*\\inputpdft\{(.*?)\}[ \n]*\\end\{center\}[ \n]*//) {
		my $thefile = "figures/$1";
		print "(CENTERED inputpdft)\n";
		#open_paragraph ();
		open_paragraph ();
		if ($thesizestr ne "") {
			print $out "\n\nX\n\n";
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
		open_paragraph ();
		print $out "\n\nX\n\n";
		close_paragraph ();

	#FIXME: this is based entirely too much on my usage :)
	} elsif ($para =~ s/^\\parbox\[c\]\{.*?\}\{\\includegraphics\[width=(.*?)\]\{(.*?)\}\}[ \n]*//) {
		my $width = $1;
		my $thefile = $2;
		print "(PARBOXED image >$width< >$thefile<\n)";
		print $out "\n\nX\n\n";

	#FIXME: not all substitutions are made, so check if more processing needs to be done
	#on caption
	} elsif ($para =~ s/^\\begin\{figure\}(\[.*?\])?[ \n]*// ||
	         $para =~ s/^\\begin\{mywrapfig\}(\[.*?\])?\{.*?\}[ \n]*// ||
	         $para =~ s/^\\begin\{myfig\}[ \n]*//) {
		print "(FIGURE)\n";
		if ($para =~ s/^(.*?)\\end\{figure\}[ \n]*//s ||
		    $para =~ s/^(.*?)\\end\{mywrapfig\}[ \n]*//s ||
		    $para =~ s/^(.*?)\\end\{myfig\}[ \n]*//s) {
			print $out "\n\nX\n\n";

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
		}

		$thm_num = $thm_num+1;
		$the_num = get_thm_number ();

		my $theid = "";
		if ($para =~ s/^[ \n]*\\label\{(.*?)\}[ \n]*//s) {
			$theid = modify_id($1);
		}

		#FIXME: hack because I sometime switch index and label
		while ($para =~ s/^[ \n]*\\index\{(.*?)\}[ \n]*//s) {
		}

		#FIXME: hack because I sometime switch index and label
		if ($para =~ s/^[ \n]*\\label\{(.*?)\}[ \n]*//s) {
			$theid = modify_id($1);
		}

		if ($title ne "") {
			print $out "\n\n$title\n\n";
		}

		open_paragraph();

	} elsif ($para =~ s/^\\end\{theorem\}[ \n]*//) {
		close_paragraph();

	} elsif ($para =~ s/^\\begin\{exercise\}\[(easy|challenging|tricky|computer project|project|little harder|harder|more challenging)\][ \n]*//) {
		my $note = $1;
		close_paragraph();
		$exercise_num = $exercise_num+1;
		my $the_num = get_exercise_number ();
		if ($para =~ s/^\\label\{([^}]*)\}[ \n]*//) {
			$theid = modify_id($1);
			print "(exercise start note >$note< id >$theid< $the_num)\n";
			print $out "\n\n";
		} else {
			print "(exercise start note >$note< $the_num)\n";
			print $out "\n\n";
		}

		open_paragraph();

	} elsif ($para =~ s/^\\begin\{exercise\}\[(.*?)\][ \n]*//s) {
		my $title = $1;
		$title =~ s|\$(.*?)\$|X|sg;
		my $index = "";
		if ($title =~ s/\\myindex\{(.*?)\}/$1/) {
			$index = $1;
		}
		close_paragraph();
		$exercise_num = $exercise_num+1;
		my $the_num = get_exercise_number ();
		if ($para =~ s/^\\label\{([^}]*)\}[ \n]*//) {
			$theid = modify_id($1);
			print "(exercise start title >$title< id >$theid< $the_num)\n";
			print $out "$title\n\n";
		} else {
			print "(exercise start title >$title< $the_num)\n";
			print $out "$title\n\n";
		}
		open_paragraph();


	} elsif ($para =~ s/^\\begin\{exercise\}[ \n]*//) {
		close_paragraph();
		$exercise_num = $exercise_num+1;
		my $the_num = get_exercise_number ();
		if ($para =~ s/^\\label\{([^}]*)\}[ \n]*//) {
			$theid = modify_id($1);
			print "(exercise start >$theid< $the_num)\n";
			print $out "\n\n";
		} else {
			print "(exercise start $the_num)\n";
			print $out "\n\n";
		}
		open_paragraph();

	} elsif ($para =~ s/^\\end\{exercise\}[ \n]*\\exsol\{//) {
		print "(exercise end)\n";
		print "(exsol start)\n";
		close_paragraph();
		print $out "\n\n"; 
		push @cltags, "exsol";
	} elsif ($para =~ s/^\\end\{exercise\}[ \n]*//) {
		print "(exercise end)\n";
		close_paragraph();
		print $out "\n\n";

	} elsif ($para =~ s/^\\begin\{example\}[ \n]*//) {
		close_paragraph();
		$example_num = $example_num+1;
		my $the_num = get_example_number ();
		if ($para =~ s/^\\label\{([^}]*)\}[ \n]*//) {
			$theid = modify_id($1);
			print "(example start >$theid<)\n";
			print $out "\n\n";
		} else {
			print "(example start)\n";
			print $out "\n\n";
		}
		open_paragraph();
	} elsif ($para =~ s/^\\end\{example\}[ \n]*//) {
		close_paragraph();
		print $out "\n\n";

	} elsif ($para =~ s/^\\begin\{remark\}[ \n]*//) {
		close_paragraph();
		$remark_num = $remark_num+1;
		my $the_num = get_remark_number ();
		if ($para =~ s/^\\label\{([^}]*)\}[ \n]*//) {
			$theid = modify_id($1);
			print "(remark start >$theid<)\n";
			print $out "\n\n";
		} else {
			print "(remark start)\n";
			print $out "\n\n";
		}
		open_paragraph();
	} elsif ($para =~ s/^\\end\{remark\}[ \n]*//) {
		close_paragraph();
		print $out "\n\n";

	} elsif ($para =~ s/^\\begin\{itemize\}[ \n]*//) {
		close_paragraph();
		print "(begin itemize)\n";
		print $out "\n\n";
	} elsif ($para =~ s/^\\end\{itemize\}[ \n]*//) {
		close_item();
		print $out "\n\n";

	} elsif ($para =~ s/^\\begin\{enumerate\}\[(.*?)\][ \n]*//) {
		close_paragraph();
		print "(begin enumerate label >$1<)\n";
		print $out "\n\n";
	} elsif ($para =~ s/^\\begin\{enumerate\}[ \n]*//) {
		close_paragraph();
		print "(begin enumerate)\n";
		print $out "\n\n";
	} elsif ($para =~ s/^\\end\{enumerate\}[ \n]*//) {
		close_item();
		print $out "\n\n";

	} elsif ($para =~ s/^\\item[ \n]*//) {
		print "(item)\n";
		open_item();
		open_paragraph();

	} elsif ($para =~ s/^\\begin\{tasks\}\[counter-format=tsk\[1\]\][ \n]*//) {
		close_paragraph();
		print "(begin tasks enumerate label 1)<)\n";
		print $out "\n\n";
	} elsif ($para =~ s/^\\begin\{tasks\}\[counter-format=tsk\[1\]\]\((.*?)\)[ \n]*//) {
		close_paragraph();
		print "(begin tasks enumerate label 1) cols=$1<)\n";
		print $out "\n\n";
	} elsif ($para =~ s/^\\begin\{tasks\}\[resume\]\((.*?)\)[ \n]*//) {
		close_paragraph();
		print "\n\n\nHUH? Don't understand resume on tasks yet!\n\n\n";
		$num_errors++;
		print "(begin resmume tasks enumerate cols=$1<)\n";
		print $out "\n\n";
	} elsif ($para =~ s/^\\begin\{tasks\}\[resume\][ \n]*//) {
		close_paragraph();
		print "\n\n\nHUH? Don't understand resume on tasks yet!\n\n\n";
		$num_errors++;
		print "(begin resmume tasks enumerate<)\n";
		print $out "\n\n";
	} elsif ($para =~ s/^\\begin\{tasks\}[ \n]*//) {
		close_paragraph();
		print "(begin tasks enumerate)\n";
		print $out "\n\n";
	} elsif ($para =~ s/^\\end\{tasks\}[ \n]*//) {
		close_item();
		print $out "\n\n";

	} elsif ($para =~ s/^\\task[ \n]*//) {
		print "(task)\n";
		open_item();
		open_paragraph();

	} elsif ($para =~ s/^([^\$\\{]*?)\}//) {
		my $line = $1;
		print "closing tag after >$line<\n\n";
		print_line($line);
		my $tagtoclose = pop @cltags;
		if ($tagtoclose eq "em") {
			print $out "";
		} elsif ($tagtoclose eq "myquote") {
			print $out "\"";
		} elsif ($tagtoclose eq "exsol") {
			print "(exsol end)\n";
			close_paragraph ();
			print $out "\n\n";
		} elsif ($tagtoclose eq "footnote") {
			#FIXME: nested paragraphs??  Does this work?
			print $out ")";
		} else {
			print "\n\nHUH???\n\nNo (or unknown =\"$tagtoclose\") tag to close\n\n";
			$num_errors++;
		}



	} elsif ($para =~ s/^\\ldots//) {
		open_paragraph_if_not_open ();
		print "...\n";

	} elsif ($para =~ s/^\\noindent//) {
		print "(noindent do nothing)\n";
	} elsif ($para =~ s/^\\sectionnewpage//) {
		print "(sectionnewpage do nothing)\n";
	} elsif ($para =~ s/^\\nopagebreak(\[.\])?//) {
		print "(nopagebreak do nothing)\n";
	} elsif ($para =~ s/^\\pagebreak(\[.\])?//) {
		print "(pagebreak do nothing)\n";

	} elsif ($para =~ s/^\\ //) {
		print "( )\n";
		print $out " "; 
	} elsif ($para =~ s/^\\-//) {
		print "(-)\n";
		open_paragraph_if_not_open ();
		print $out "-"; 
	} elsif ($para =~ s/^\\medskip *//) {
		print "(medskip)\n";
		if ($inparagraph) {
			print $out "\n\n";
		}
	} elsif ($para =~ s/^\\bigskip *//) {
		print "(bigskip)\n";
		if ($inparagraph) {
			print $out "\n\n";
		}
	} elsif ($para =~ s/^\\\\\[[0-9a-z]*\]// ||
		 $para =~ s/^\\\\//) {
		print "(BR)\n";
		if ($inparagraph) {
			print $out "\n\n";
		}
	} elsif ($para =~ s/^\\enspace//) {
		print "(enspace)\n";
		open_paragraph_if_not_open ();
		print $out " "; 
	} elsif ($para =~ s/^\\quad//) {
		print "(quad)\n";
		open_paragraph_if_not_open ();
		print $out " "; 
	} elsif ($para =~ s/^\\qquad//) {
		print "(qquad)\n";
		open_paragraph_if_not_open ();
		print $out " "; 
	} elsif ($para =~ s/^\\LaTeX//) {
		print "(LaTeX)\n";
		open_paragraph_if_not_open ();
		print $out "LaTeX"; 

	} elsif ($para =~ s/^\\footnote\{//) {
		print "(FOOTNOTE start)\n";
		open_paragraph_if_not_open ();
		print $out " ("; 
		push @cltags, "footnote";

	} elsif ($para =~ s/^\\begin\{samepage\}//) {
		print "(begin samepage} do nothing)\n";

	} elsif ($para =~ s/^\\end\{samepage\}//) {
		print "(end{samepage} do nothing)\n";

	} elsif ($para =~ s/^\\begin\{mysamepage\}//) {
		print "(begin mysamepage} do nothing)\n";

	} elsif ($para =~ s/^\\end\{mysamepage\}//) {
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

close ($in); 
close ($out); 
 
print "\nDone! (number of errors $num_errors)\n"; 
