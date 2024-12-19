# Notes on Diffy Qs: Differential Equations for Engineers

A free online textbook.  See https://www.jirka.org/diffyqs/

## Branches:

* ``master`` branch is the current working version, edition 6.
* ``edition5`` branch is the now obsolete edition 5, no updates are planned for this version.

## Files

* ``diffyqs.tex`` is the main file, no real content here, the content is in the chapter files.
* ``ch-*.tex`` are the files with the content of the various chapters.
* ``ap-*.tex`` are the files with the content of the various apendices (only one right now).
* ``diffyqssetup.sty`` is the LaTeX preamble for the PDF version.
* ``mywrapfig.sty`` is a slightly modified wrapfig.sty (fixing intextsep nonsense).

* Figures are in ``figures/``

* ``cover.*`` is the blue lulu version of the cover.
* ``logo.png`` is a small logo for the web version.

The shell(``.sh``) and Perl(``.pl``) scripts here are mostly really hacky ways to just do things.  Feel free to ignore them.

* ``runpdf.sh`` does a thorough job of compiling the source to a pdf
* ``getstats.sh`` gets statistics about the current version like number of exercises and such.
* ``convert-to-mbx.*`` is a conversion script to PreTeXt (used to be MathBookXML or MBX) for an online version.  The output is not plain PreTeXt, it contains custom elements, so it requires a custom xsl file, see ``diffyqs-html.xsl``.  The script to run is ``convert-to-mbx.sh``, which is a shell script.  This among other things runs ``convert-to-mbx.pl``, which actually does the conversion, then it runs ``xsltproc`` on the result.  The result is stored in ``html`` subdirectory (old one is moved out of the way to ``html.(randomnumber)``).  Some svg and png figures are created in the process, they can be optimized by ``optimize-svgs.sh`` (uses ``svgo`` which you might have to install).  (There used to be pngs generated, so there is also an unused ``optimize-pngs.sh``).  Notice that an older ``svgo`` clobbers some of the more complicated figures without disabeling one of the plugins.  So best to check the output for correctness.  There is a flag ``--full`` for doing the entire conversion and optimization.
* ``diffyqs-html.xsl`` is the xsl to use to convert the PreTeXt output.
* ``fixup-html-file.pl`` is a perl script invoked in the web version generation.
* ``extra.css`` is the extra CSS for the web version.
* ``pdftopng.sh`` is a script to convert a pdf figure to a png.
* ``resizepdftocrownquatro.sh`` is a script to resize a pdf into a crown quatro size paper, run it with ``./resizepdftocrownquatro.sh diffyqs``, which will take ``diffyqs.pdf`` and produce ``diffyqs-cq.pdf``.

## Notes

The tex sources require a recent LaTeX.  I usually use a relatively recent TeXLive.  With an older version you might get issues with footmisc vs hyperref (bad links to footnotes, but it probably will still work otherwise).  If your LaTeX is even older and does not have a recent enough ocgx2 package, you can simply comment out that line in ``diffyqssetup.sty``.

## Old stuff

Some of the files in ``old/``:

* ``diffyqssetup-tex4ht.sty`` is the preamble for creating the old web version with tex4ht, but this is unlikely to work for anyone and clearly hasn't been updated in a while.  Note that the google tracking code for my website is here, so if you want to use this you should change that first.
