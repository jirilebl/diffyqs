#!/bin/sh
# This is really overly anal
for n in 1 2 3 4 5 ; do
  pdflatex diffyqs
  makeindex diffyqs
done

pdflatex diffyqs
