#!/bin/zsh

echo NOT OPTIMIZING SVG...

exit 0

echo OPTIMIZING SVG...
for n in *.svg ; do
  #echo svgo --disable=convertPathData --multipass $n
  #svgo --disable=convertPathData --multipass $n
  echo svgo --multipass $n
  svgo --multipass --config svgo.config.mjs $n
done
