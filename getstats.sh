#!/bin/sh

echo
echo Exercises:"                    \t"`grep '^[\]begin{exercise' *.tex | wc -l`
echo Figures:"                      \t"`grep '^[\]begin{\(figure\|diffyfloatingfigure\)' *.tex | wc -l`
echo '\\---> which are simple insets:'"\t"`grep '^[\]begin{diffyfloatingfiguresimple' *.tex | wc -l`
echo Tables:"                       \t"`grep '^[\]begin{table}' *.tex | wc -l`

echo
