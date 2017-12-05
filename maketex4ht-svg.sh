#!/bin/zsh
echo READ maketex4ht-svg.sh file for more info
echo
#
# make sure to enable the svg in diffyqssetup-tex4ht.sty
#
# must use tex4ht.env, using correct dvisvgm line (--exact!!!)
# then below objectify.pl to stick in the pngs into the html
# it also adds a viewport line to the header to work well on android
#
# The figures run with figurerun.sh are handled weirdly, png goes through,
# but then we replace it with the .svg in objectify.pl, and use the png as
# fallback.
#
# if testing remove the google analytics from 
#
#
echo MAKE SURE TO USE diffyqssetup-tex4ht.sty
echo MAKE SURE TO copy tex4ht.env here
read FOO
echo RUNNING FIGURES ...
./figurerun.sh 72
echo RUNNING HTLATEX ...
echo htlatex diffyqs "html,index=2,3,fn-in,next" 'iso8859/1/charset/uni/!' "-p"
htlatex diffyqs "html,index=2,3,fn-in,next" 'iso8859/1/charset/uni/!' "-p"
echo tex '\def\filename{{diffyqs}{idx}{4dx}{ind}} \input idxmake.4ht'
tex '\def\filename{{diffyqs}{idx}{4dx}{ind}} \input idxmake.4ht'
echo makeindex -o diffyqs.ind diffyqs.4dx
makeindex -o diffyqs.ind diffyqs.4dx
echo htlatex diffyqs "html,index=2,3,fn-in,next" 'iso8859/1/charset/uni/!'
htlatex diffyqs "html,index=2,3,fn-in,next" 'iso8859/1/charset/uni/!'
echo RUNNING OBJECTIFY...
for n in *.html ; do
	if ./objectify.pl $n ; then
		echo "SUCCESS ON $n"
		echo
	else
		echo "FAILED ON $n"
		echo
		exit 1
	fi
done
#echo optipng -o7 '*.png'
#optipng -o7 *.png
echo QUANTIZING...
for n in `file diffyqs*.png | grep -v colormap | sed 's/:.*$//'` ; do pngnq -s 1 -f $n ; mv ${n%.png}-nq8.png $n ; done
echo OPTIMIZING...
echo optipng -o7 'diffy*.png'
optipng -o7 diffy*.png
echo 'for k in 0 5 ; do for n in diffyq*.png ; do pngout-static -f$k $n ; done ; done'
for k in 0 5 ; do for n in diffyq*.png ; do pngout-static -f$k $n ; done ; done
echo advdef -z -4 'diffy*.png'
advdef -z -4 diffy*.png
#echo 'for n in *.png ; do pngtinycache.sh "$n" ; done'
#for n in *.png ; do pngtinycache.sh "$n" ; done
#echo 'scp *.html *.png *.css *.svg zinc.5z.com:/var/www/jirka/diffyqs/htmlver/'
#scp *.html *.png *.css *.svg zinc.5z.com:/var/www/jirka/diffyqs/htmlver/
