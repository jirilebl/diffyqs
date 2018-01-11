# This is hackish, but I can't figure out how to modify the html output otherwise
while($line = <>)
{
	if ($line =~ m/<a class="index-button.*index-1.html.*Index/) {
		print "<a class=\"index-button toolbar-item button\" href=\"http://www.jirka.org/diffyqs/\" title=\"Home\" alt=\"Book Home\">Home</a>\n";
		print "<a class=\"index-button toolbar-item button\" href=\"http://www.jirka.org/diffyqs/diffyqs.pdf\" title=\"PDFt=\"PDF\">PDF</a>\n";
		print "<a class=\"index-button toolbar-item button\" style=\"width:100px;\" href=\"https://smile.amazon.com/dp/1541329058\" title=\"Paperback\" alt=\"Buy Paperback\">Paperback</a>\n";
	}
	if ($line =~ m/<\/head>/) {
		# Fast preview doesn't seem worth it and it could be confusing since it's not quite right so disable it
		print "<script type=\"text/x-mathjax-config\">\n";
		print " MathJax.Hub.Config({\n";
		print "  \"fast-preview\": {\n";
		print "   disabled: true,\n";
		print "  },\n";
		print " });\n";
		print "</script>\n";
		
		print "<style>\n";
		# Not really critical, avoids flashing some LaTeX code on initial load, as external .css files get loaded slowly
		print " .hidden-content { display:none; }\n";
		# This is for the print PDF warning below
		print " .print-pdf-warning { display:none; }\n";
		print " \@media print { .print-pdf-warning { display:inline; } }\n";
		print "</style>\n";
	}
	if ($line =~ m/<\/body>/) {
		print "<span class=\"print-pdf-warning\">\n";
		print " <em>For a higher quality printout use the PDF version: <tt>http://www.jirka.org/diffyqs/diffyqs.pdf</tt></em>\n";
		print "</span>\n";
	}
	$line =~ s/>Authored in PreTeXt</>Created with PreTeXt</;
	print $line;
}
