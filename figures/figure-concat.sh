#!/bin/zsh

n1="$1"
n2="$2"

out="$3"

sed -e "s/THEFILE1/$n1/" < figure-concat-in.tex | sed -e "s/THEFILE2/$n2/"  > figure-concat.tex
echo running pdflatex...
pdflatex figure-concat
pdflatex figure-concat
cp figure-concat.pdf "$3"
