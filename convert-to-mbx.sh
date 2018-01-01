#!/bin/zsh
echo THIS POSSIBLY WONT WORK, IT IS A WORK IN PROGRESS!  Do ^C to get out
read
#exit 0

echo
echo RUNNING FIGURES...
echo

cd figures
./figurerun.sh 192
cd ..

echo
echo RUNNING convert-to-mbx.pl ...
echo


perl convert-to-mbx.pl

#xmllint --format -o diffyqs-out2.xml diffyqs-out.xml

echo
echo MOVING OLD html, CREATING NEW html, COPYING figures/ in there
echo

mv html html.$RANDOM$RANDOM$RANDOM
mkdir html
cd html
cp -a ../figures .

echo
echo RUNNING xsltproc
echo

xsltproc ../diffyqs-html.xsl ../diffyqs-out.xml

echo
echo FIXING UP HTML ...
echo

for n in *.html; do
	perl ../fixup-html-file.pl < $n > tmpout
	mv tmpout $n
done

echo
echo DONE ...
echo
