#!/bin/sh
echo THIS WONT WORK, IT NEEDS updating!
read
exit 0

perl convert-to-mbx.pl
#xmllint --format -o diffyqs-out2.xml diffyqs-out.xml
xsltproc ~/mathbook/xsl/mathbook-latex.xsl diffyqs-out.xml
