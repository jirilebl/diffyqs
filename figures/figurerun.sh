#!/bin/zsh

res="$1"

for n in figures/*.pdf_t ; do
	./figurerun-one.sh "$n" "$res"
done
