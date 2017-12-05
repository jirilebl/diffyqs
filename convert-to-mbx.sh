#!/bin/sh
perl convert-to-mbx.pl
#xmllint --format -o diffyqs-out2.xml diffyqs-out.xml
xsltproc ~/mathbook/xsl/mathbook-latex.xsl diffyqs-out.xml
