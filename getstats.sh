#!/bin/sh

echo
<<<<<<< HEAD
echo Chapters:"                     \t"`grep '^[\]chapter\**{' *.tex | wc -l`
echo Sections:"                     \t"`grep '^[\]section\**{' *.tex | wc -l`
echo
echo Exercises:"                    \t"`grep '^[\]begin{exercise' *.tex | wc -l`
echo '\\---> with solutions:         '"\t"`grep '^[\]exsol' *.tex | wc -l`
echo
echo Figures:"                      \t"`grep '^[\]begin{\(figure\|diffyfloatingfigure\)' *.tex | wc -l`
echo '\\---> which are simple insets:'"\t"`grep '^[\]begin{diffyfloatingfiguresimple' *.tex | wc -l`
echo
=======
echo Exercises:"                    \t"`grep '^[\]begin{exercise' *.tex | wc -l`
echo Figures:"                      \t"`grep '^[\]begin{\(figure\|diffyfloatingfigure\)' *.tex | wc -l`
echo '\\---> which are simple insets:'"\t"`grep '^[\]begin{diffyfloatingfiguresimple' *.tex | wc -l`
>>>>>>> 330576e83ba7a57696e0ac59055726e59c52a1d6
echo Tables:"                       \t"`grep '^[\]begin{table}' *.tex | wc -l`

echo
