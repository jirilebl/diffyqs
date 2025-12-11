#!/bin/zsh

n="$1"
res="$2"

sed -e "s/THEFILE/${n%.pdf_t}/" < figurerun-in.tex > figurerun.tex
echo running pdflatex...
pdflatex figurerun
pdflatex figurerun
pdfcrop figurerun.pdf ${n%.pdf_t}-tex4ht.pdf
rm figurerun.pdf
#echo running pdftops...
#pdftops -eps ${n%.pdf_t}-tex4ht.pdf ${n%.pdf_t}-tex4ht.eps
echo running pdftocairo...
pdftocairo -svg ${n%.pdf_t}-tex4ht.pdf ${n%.pdf_t}-tex4ht.svg
#echo running svgo
#svgo --config svgo.config.mjs ${n%.pdf_t}-tex4ht.svg
echo running svgo-ll
svgo-ll --enable=round ${n%.pdf_t}-tex4ht.svg
#echo running pdf2svg...
#pdf2svg ${n%.pdf_t}-tex4ht.pdf ${n%.pdf_t}-tex4ht.svg
#echo running mutool...
#mutool convert -F svg -o ${n%.pdf_t}-tex4ht.svg ${n%.pdf_t}-tex4ht.pdf
#echo running inkscape to convert to svg
#inkscape --export-type=svg ${n%.pdf_t}-tex4ht.pdf --export-filename=${n%.pdf_t}-tex4ht.svg
#inkscape \
#  --without-gui \
#  --file=${n%.pdf_t}-tex4ht.pdf \
#  --export-plain-svg=${n%.pdf_t}-tex4ht.svg
#echo running dvisvgm to convert to svg...
#dvisvgm -n -O --pdf --output=${n%.pdf_t}-tex4ht.svg ${n%.pdf_t}-tex4ht.pdf
#dvisvgm -f woff2,autohint -O --pdf --output=${n%.pdf_t}-tex4ht.svg ${n%.pdf_t}-tex4ht.pdf
#echo running pdftopng...
#../pdftopng.sh ${n%.pdf_t}-tex4ht.pdf ${n%.pdf_t}-tex4ht.png $res
#echo removing pdf...
#rm ${n%.pdf_t}-tex4ht.pdf
#echo running optipng...
#optipng ${n%.pdf_t}-tex4ht.png
#echo running pngout...
#for k in 0 5 ; do pngout-static -f$k ${n%.pdf_t}-tex4ht.png ; done
#echo running advdef...
#advdef -z -4 ${n%.pdf_t}-tex4ht.png
