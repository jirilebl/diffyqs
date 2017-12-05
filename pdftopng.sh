#!/bin/sh
#gs -sDEVICE=png16m \
   #-dNOPAUSE -dBATCH -dSAFER \
   #-sOutputFile="$2" \
   #-dTextAlphaBits=4 \
   #-dGraphicsAlphaBits=4 \
   #-r$3 \
   #"$1"
convert -background transparent -density "$3"x"$3"  "$1" "$2"
