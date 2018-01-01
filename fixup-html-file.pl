while($line = <>)
{
	if ($line =~ m/<a class="index-button.*index-1.html.*Index/) {
		print "<a class=\"index-button toolbar-item button\" href=\"http://www.jirka.org/diffyqs/\" title=\"Home\" alt=\"Book Home\">Home</a>\n";
		print "<a class=\"index-button toolbar-item button\" style=\"width:100px;\" href=\"https://smile.amazon.com/dp/1541329058\" title=\"Paperback\" alt=\"Buy Paperback\">Paperback</a>\n";
	} elsif ($line =~ m/^<\/head>/) {
		print "<style>\n";
		print ".main #content { max-width: 800px; }\n";
		print "#masthead.smallbuttons { max-width: 1104px; }\n";
		print ".container.has-sidebar-left, .has-sidebar-left .container { max-width: 1104px; }\n";
		print "</style>\n";
	}
	print $line;
}
