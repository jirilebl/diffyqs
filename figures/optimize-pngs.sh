#!/bin/zsh

echo OPTIMIZING...
#echo optipng -o7 'diffy*.png'
#optipng -o7 diffy*.png
echo optipng '*.png'
optipng *.png

#optipng reduces to pallete mode if possible, no need to do
#quantizing first on those, only those with honestly more than 256 colors.
echo QUANTIZING and REOPTIMIZING those left in RGB...
for n in `file *.png | grep -v colormap | sed 's/:.*$//'` ; do
	echo Working on $n...
	#pngnq -s 1 -f $n
	#mv -f ${n%.png}-nq8.png $n
	pngquant -s 1 -Q 0-80 -f $n
	mv -f ${n%.png}-fs8.png $n
	optipng $n
done

echo OPTIMIZING WITH advdef...
echo advdef -z -4 '*.png'
advdef -z -4 *.png
