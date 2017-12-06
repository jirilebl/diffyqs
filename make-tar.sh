#!/bin/sh
FILES=`git ls-files | fgrep -v '.gitignore' | fgrep -v 'make-tar.sh' | grep -v '.gel$' | grep -v '[1-4]\.[1-6]\.tex' | grep -v -- '-tex4ht.png'`

rm -fR diffyqs
mkdir diffyqs
cp $FILES diffyqs

rm -f diffyqs.tar.gz
tar cvf diffyqs.tar diffyqs/
gzip -9 diffyqs.tar

rm -fR diffyqs
