# This is hackish, but I can't figure out how to modify the html output otherwise
while($line = <>)
{
	if ($line =~ m/<a class="index-button.*index-1.html.*Index/) {
		print "<a class=\"index-button toolbar-item button\" href=\"http://www.jirka.org/diffyqs/\" title=\"Home\" alt=\"Book Home\">Home</a>\n";
		print "<a class=\"index-button toolbar-item button\" href=\"http://www.jirka.org/diffyqs/diffyqs.pdf\" title=\"PDFt=\"PDF\">PDF</a>\n";
		print "<a class=\"index-button toolbar-item button\" style=\"width:100px;\" href=\"https://smile.amazon.com/dp/1541329058\" title=\"Paperback\" alt=\"Buy Paperback\">Paperback</a>\n";
	}
	if ($line =~ m/<\/head>/) {
		print "<script type=\"text/x-mathjax-config\">\n";
		print " MathJax.Hub.Config({\n";
		print "  \"fast-preview\": {\n";
		print "   disabled: true,\n";
		print "  },\n";
		print " });\n";
		print "</script>\n";
		
		# Not really critical, but makes initial look slightly nicer as external .css files get loaded slowly
		print "<style>\n";
		print " .hidden-content { display:none; }\n";
		print "</style>\n";
	}
	print $line;
}
