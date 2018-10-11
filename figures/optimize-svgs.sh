#!/bin/zsh

echo OPTIMIZING SVG...
for n in *.svg ; do
  echo svgo --disable=convertPathData --multipass $n
  svgo --disable=convertPathData --multipass $n
done
