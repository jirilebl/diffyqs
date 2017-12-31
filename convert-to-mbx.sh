#!/bin/sh
echo THIS WONT WORK, IT NEEDS updating!
read
exit 0

cd figures
./figurerun.sh 192
cd ..

perl convert-to-mbx.pl

#xmllint --format -o diffyqs-out2.xml diffyqs-out.xml

mkdir html
cd html

xsltproc ../diffyqs-html.xsl ../diffyqs-out.xml
