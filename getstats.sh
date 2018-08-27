#!/bin/sh

echo
echo Chapters:"                     \t"`grep '^[\]chapter\**{' *.tex | wc -l`
echo Sections:"                     \t"`grep '^[\]section\**{' *.tex | wc -l`
echo
echo Exercises:"                    \t"`grep '^[\]begin{exercise' *.tex | wc -l`
echo '\\---> with solutions:         '"\t"`grep '^[\]exsol' *.tex | wc -l`
echo
echo Figures:"                      \t"`grep '^[\]begin{\(myfig\|mywrapfig\)' *.tex | wc -l`
echo '\\---> which are simple insets:'"\t"`grep '^[\]begin{mywrapfigsimp' *.tex | wc -l`
echo
echo Tables:"                       \t"`grep '^[\]begin{table}' *.tex | wc -l`

echo
