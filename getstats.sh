#!/bin/bash

echo
echo -e Chapters:"                     \t"`grep '^[\]chapter\**{' *.tex | wc -l`
echo -e Sections:"                     \t"`grep '^[\]section\**{' *.tex | wc -l`
echo
echo -e Exercises:"                    \t"`grep '^[\]begin{exercise' *.tex | wc -l`
echo -e '\\---> with solutions:         '"\t"`grep '^[\]exsol' *.tex | wc -l`
echo
echo -e Figures:"                      \t"`grep '^[\]begin{\(myfig\|mywrapfig\)' *.tex | wc -l`
echo -e '\\---> which are simple insets:'"\t"`grep '^[\]begin{mywrapfigsimp' *.tex | wc -l`
echo
echo -e Tables:"                       \t"`grep '^[\]begin{table}' *.tex | wc -l`
echo
echo -e Footnotes:"                    \t"`grep '[\]footnote{' *.tex | wc -l`

echo
