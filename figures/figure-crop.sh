#!/bin/sh
cp -f $1 $1.bak
pdfcrop $1 .foo.pdf && mv .foo.pdf $1 && rm .foo.pdf
