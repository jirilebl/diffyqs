#!/bin/sh
cp -f $1 $1.bak
pdfcrop $1 .foo.pdf && cp .foo.pdf $1 && rm -f .foo.pdf
