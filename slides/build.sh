#!/bin/sh
echo Building

for n in *.tex ; do
	echo =============================
	p=`basename $n .tex`".pdf"
	echo $n '-->' $p
	#rubber -d --synctex $n
	latexmk -pdf -synctex=1 "$n"
done

echo =============================
echo Making deslides.zip

rm -f deslides.zip
zip deslides *.pdf
