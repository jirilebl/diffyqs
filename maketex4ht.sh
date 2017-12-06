#!/bin/zsh
echo READ maketex4ht.sh file for more info
echo
#
# must use tex4ht.env, there we upscale all pngs to 200 dpi using dvipng,
# then below downscale.pl does some magic on the html files to add half
# the size of the images, it also removes duplicates using md5sum
# it also adds a viewport line to the header to work well on android
#
# if testing remove the google analytics
#
echo MAKE SURE TO USE diffyqssetup-tex4ht.sty
echo MAKE SURE TO copy tex4ht.env here
read FOO

echo REMOVING html and old pngs and css
echo rm '*.html' 'diffy*.png' '*.css'
rm *.html diffy*.png *.css

echo RUNNING FIGURES at 192dpi, will be downscaled to 96dpi later...
cd figures
./figurerun.sh 192
cd ..
echo htlatex diffyqs "html,index=2,3,fn-in,next,uni-html4" ' -cunihtf' "-p"
htlatex diffyqs "html,index=2,3,fn-in,next,uni-html4" ' -cunihtf' "-p"
echo tex '\def\filename{{diffyqs}{idx}{4dx}{ind}} \input idxmake.4ht'
tex '\def\filename{{diffyqs}{idx}{4dx}{ind}} \input idxmake.4ht'
echo makeindex -o diffyqs.ind diffyqs.4dx
makeindex -o diffyqs.ind diffyqs.4dx
echo htlatex diffyqs "html,index=2,3,fn-in,next,uni-html4" ' -cunihtf'
htlatex diffyqs "html,index=2,3,fn-in,next,uni-html4" ' -cunihtf'

echo OPTIMIZING...
#echo optipng -o7 'diffy*.png'
#optipng -o7 diffy*.png
echo optipng 'diffy*.png'
optipng diffy*.png

#echo 'for k in 0 5 ; do for n in diffyq*.png ; do pngout-static -f$k $n ; done ; done'
#for k in 0 5 ; do for n in diffyq*.png ; do pngout-static -f$k $n ; done ; done
for n in diffyq*.png ; do pngout-static $n ; done

#optipng reduces to pallete mode if possible, no need to do
#quantizing first on those, only those with honestly more than 256 colors.
echo QUANTIZING and REOPTIMIZING those left in RGB...
for n in `file diffyqs*.png | grep -v colormap | sed 's/:.*$//'` ; do
	echo Working on $n...
	pngnq -s 1 -f $n
	mv -f ${n%.png}-nq8.png $n
	optipng $n
	pngout-static $n
done

echo OPTIMIZING WITH advdef...
echo advdef -z -4 'diffy*.png'
advdef -z -4 diffy*.png

echo RUNNING DOWNSCALE...
md5sum *.png > md5db.txt
awk '{ print $1 }' < md5db.txt | sort | uniq -c > md5counts.txt
for n in *.html ; do
	if ./downscale.pl $n ; then
		echo "SUCCESS ON $n"
		echo
	else
		echo "FAILED ON $n"
		echo
		exit 1
	fi
done

echo OPTIMIZING HTML...
echo 'tidy -c -n -w 0 -m --hide-comments yes -q *.html'
tidy -c -n -w 0 -m --hide-comments yes -q *.html
# This screws up the media selectors so don't do it
#echo 'csstidy diffyqs.css --template=high out-diffyqs.css && mv out-diffyqs.css diffyqs.css'
#csstidy diffyqs.css --template=high out-diffyqs.css && mv -f out-diffyqs.css diffyqs.css
echo UNIQUING CSS...
uniq diffyqs.css > out-diffyqs.css
mv -f out-diffyqs.css diffyqs.css

#echo 'for n in *.png ; do pngtinycache.sh "$n" ; done'
#for n in *.png ; do pngtinycache.sh "$n" ; done
#echo 'scp *.html *.png *.css zinc.5z.com:/var/www/jirka/diffyqs/htmlver/'
#scp *.html *.png *.css zinc.5z.com:/var/www/jirka/diffyqs/htmlver/
