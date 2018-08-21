Notes on Diffy Qs: Differential Equations for Engineers
-------------------------------------------------------

A free online textbook.  See http://www.jirka.org/diffyqs/

* ``master`` branch is the current working version, currently it is what will become edition 6.
* ``edition5`` branch is edition5 and only smaller fixes or smaller changes that don't really change content or pagination go here

* ``diffyqs.tex`` is the main file, no real content here, that's in the chapter files
* ``ch-*.tex`` are the files with the content of the various chapters
* ``diffyqssetup.sty`` is the preamble for the PDF version

* Figures are in ``figures/``

* ``cover.*``: the blue lulu version of the cover
* ``logo.png``: small logo for the web version

The shell(``.sh``) and Perl(``.pl``) scripts here are really for me and are really hacky ways to just do things.  Most of them are for generating the web version.  Feel free to ignore them.

* ``convert-to-mbx.*`` is work in progress conversion script to PreTeXt (used to be MathBookXML or MBX) for a better looking online version.  The output is not plain PreTeXt, it contains custom elements.  The script to run is ``convert-to-mbx.sh``, which is a shell script.  This runs ``convert-to-mbx.pl`` which actually does the conversion, then it runs ``xsltproc`` on the result.  The result is stored in ``html`` subdirectory (old one is moved out of the way).  Some svg and png figures are created in the process, they can be optimized by ``optimize-svgs.sh`` (uses ``svgo`` which you might have to install).  Currently uses the svgs by default with pngs as fallbacks.  Notice that ``svgo`` currently clobbers some of the more complicated figures without disabeling one of the plugins.  So best to check the output for correctness.
* ``diffyqs-html.xsl``: The xsl to use to convert the PreTeXt output.

The tex sources require a very recent LaTeX, if your latex does not have a recent enough ocgx2 package, you can simply comment out that line in
diffyqssetup.sty.

Some of the files in ``old/`` (not in the .tar.gz file from the website):

* ``diffyqssetup-tex4ht.sty`` is the preamble for creating the old web version with tex4ht, but this is unlikely to work for anyone but me at the moment.  Also note that the google tracking code for my website is here, so if you want to use this you should change that first.
