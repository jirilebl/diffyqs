# Notes on Diffy Qs: Differential Equations for Engineers

A free online textbook.  See http://www.jirka.org/diffyqs/

## Branches:

* ``master`` branch is the current working version, version 6.
* ``edition5`` branch is the now obsolete edition 5, no updates are planned for this version.

## Files

* ``diffyqs.tex`` is the main file, no real content here, that's in the chapter files
* ``ch-*.tex`` are the files with the content of the various chapters
* ``ap-*.tex`` are the files with the content of the various apendices (only one right now)
* ``diffyqssetup.sty`` is the preamble for the PDF version
* ``mywrapfig.sty`` is a slightly modified wrapfig.sty (fixing intextsep nonsense)

* Figures are in ``figures/``

* ``cover.*``: the blue lulu version of the cover
* ``logo.png``: small logo for the web version

The shell(``.sh``) and Perl(``.pl``) scripts here are mostly really hacky ways to just do things.  Feel free to ignore them.

* ``runpdf.sh`` does a thorough job of compiling the source to a pdf
* ``getstats.sh`` gets statistics about the current version like number of exercises, and such.
* ``convert-to-mbx.*`` is work in progress conversion script to PreTeXt (used to be MathBookXML or MBX) for a better looking online version.  The output is not plain PreTeXt, it contains custom elements.  The script to run is ``convert-to-mbx.sh``, which is a shell script.  This runs ``convert-to-mbx.pl`` which actually does the conversion, then it runs ``xsltproc`` on the result.  The result is stored in ``html`` subdirectory (old one is moved out of the way).  Some svg and png figures are created in the process, they can be optimized by ``optimize-svgs.sh`` (uses ``svgo`` which you might have to install) and ``optimize-pngs.sh``.  Currently uses the svgs by default with pngs as fallbacks.  Notice that ``svgo`` currently clobbers some of the more complicated figures without disabeling one of the plugins.  So best to check the output for correctness.  There is a flag ``--full`` for doing the entire conversion and optimization.
* ``diffyqs-html.xsl``: The xsl to use to convert the PreTeXt output.
* ``fixup-html-file.pl``: a perl script invoked in the web version generation
* ``extra.css``: extra CSS for the web version.
* ``pdftopng.sh`` is a script to convert a pdf figure to a png.
* ``resizepdftocrownquatro.sh`` is a script to resize a pdf into a crown quatro size paper, run it with ``resizepdftocrownquatro diffyqs`` which will take ``diffyqs.pdf`` and produce ``diffyqs-cq.pdf``

## Notes

The tex sources require a very recent LaTeX, if your latex does not have a recent enough ocgx2 package, you can simply comment out that line in ``diffyqssetup.sty``.

## Old stuff

Some of the files in ``old/``:

* ``diffyqssetup-tex4ht.sty`` is the preamble for creating the old web version with tex4ht, but this is unlikely to work for anyone.  Also note that the google tracking code for my website is here, so if you want to use this you should change that first.
