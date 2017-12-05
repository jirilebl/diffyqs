#!/bin/zsh
#echo MAKE SURE TO USE diffyqssetup-tex4ht.sty
#read FOO
#echo htlatex diffyqs "html,3,next" 'iso8859/1/charset/uni/!'
#htlatex diffyqs "html,3,next" 'iso8859/1/charset/uni/!'
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
#echo 'scp *.html *.png *.css zinc.5z.com:/var/www/jirka/diffyqs/htmlver/'
#scp *.html *.png *.css zinc.5z.com:/var/www/jirka/diffyqs/htmlver/
