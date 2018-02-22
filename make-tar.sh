#!/bin/sh
FILES=`git ls-files | fgrep -v '.gitignore' | fgrep -v 'make-tar.sh' | grep -v -- '^[a-z]*/'`
FIGUREFILES=`git ls-files | fgrep -v '.gitignore' | fgrep -v 'make-tar.sh' | grep -- '^figures/'`

rm -fR diffyqs
mkdir diffyqs
mkdir diffyqs/figures
cp $FILES diffyqs
cp $FIGUREFILES diffyqs/figures/

rm -f diffyqs.tar.gz
tar cvf diffyqs.tar diffyqs/
gzip -9 diffyqs.tar

rm -fR diffyqs
