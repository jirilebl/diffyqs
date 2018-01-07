#!/bin/zsh
echo Conversion to HTML through PreTeXt.  It is still beta quality and work in
echo progress.  Do ^C to get out.
echo 
echo You should first run with --runpdft --optimize-svg --optmize-png which
echo runs the pdft figures and then also optimizes pngs and svgs.  Without
echo --runpdft some figures will be missing.  You can also use --full
echo which does all three arguments.
echo Optimizations are the optimize-pngs.sh and optimize-svgs.sh in figures/
echo
echo To rerun all figures first do \"rm "*-mbx.*" "*-tex4ht.*"\", or run
echo this script with --kill-generated
echo

PDFT=no
OPTPNG=no
OPTSVG=no

# parse parameters
while [ "$1" != "" ]; do
    case $1 in
        -h | --help)
            exit
            ;;
        --runpdft)
	    echo (runpdft) Will run pdf_t figures
	    PDFT=yes
            ;;
        --optimize-png)
	    echo (optimize-png) Will run optimize-pngs.sh
	    OPTPNG=yes
            ;;
        --optimize-svg)
	    echo (optimize-svg) Will run optimize-svgs.sh
	    OPTSVG=yes
	    ;;
        --full)
	    echo (full) Will run pdf_t optimize pngs and svgs
	    PDFT=yes
	    OPTPNG=yes
	    OPTSVG=yes
            ;;
        --kill-generated)
	    echo (kill-generated) Killing generated figures and exiting.
	    cd figures
	    rm *-mbx.svg
	    rm *-mbx.png
	    rm *-tex4ht.svg
	    rm *-tex4ht.png
	    cd ..
	    exit
	    ;;
        *)
            echo "ERROR: unknown parameter \"$PARAM\""
            exit 1
            ;;
    esac
    shift
done


# wait for enter or ^C
read

if [ "$PDFT" = "yes" ] ; then
	echo
	echo RUNNING FIGURES...
	echo

	cd figures
	./figurerun.sh 192
	cd ..
fi

echo
echo RUNNING convert-to-mbx.pl ...
echo


perl convert-to-mbx.pl

#xmllint --format -o diffyqs-out2.xml diffyqs-out.xml

if [ "$OPTPNG" = "yes" ] ; then
	echo
	echo OPTIMIZING PNG...
	echo

	cd figures
	./optimize-pngs.sh
	cd ..
fi

if [ "$OPTSVG" = "yes" ] ; then
	echo
	echo OPTIMIZING SVG...
	echo

	cd figures
	./optimize-svgs.sh
	cd ..
fi

echo
echo MOVING OLD html, CREATING NEW html, COPYING figures/ in there
echo

mv html html.$RANDOM$RANDOM$RANDOM
mkdir html
cd html
cp -a ../figures .
cp ../extra.css .
cp ../logo.png .

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
echo Perhaps now do: rsync -av -e ssh html zinc.5z.com:/var/www/jirka/diffyqs/
echo Make sure you have run the script with --full before ...
echo
