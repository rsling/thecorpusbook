FIGUREDIR = figures
CACHEDIR = cache

pdf: thecorpusbook.bbl thecorpusbook.pdf 

all: pod cover

complete: index thecorpusbook.pdf

index:  thecorpusbook.snd
 
thecorpusbook.pdf: thecorpusbook.aux
	xelatex thecorpusbook 

thecorpusbook.aux: thecorpusbook.tex $(wildcard local*.tex)
	xelatex -no-pdf thecorpusbook 

# Before the normal LSP make begins, we need to make TeX from Rnw.
thecorpusbook.tex: thecorpusbook.Rnw $(wildcard chapters/*.Rnw) $(wildcard chapters/*.tex)
	Rscript \
	  -e "library(knitr)" \
	  -e "knitr::knit('$<','$@')"

# Make R files.
%.R: %.Rnw
	Rscript -e "Sweave('$^', driver=Rtangle())"

# Create only the book.
thecorpusbook.bbl: thecorpusbook.tex localbibliography.bib  
	xelatex -no-pdf thecorpusbook
	biber thecorpusbook


thecorpusbook.snd: thecorpusbook.bbl
	touch thecorpusbook.adx thecorpusbook.sdx thecorpusbook.ldx
	sed -i s/.*\\emph.*// thecorpusbook.adx 
	sed -i 's/hyperindexformat{\\\(infn {[0-9]*\)}/\1/' thecorpusbook.sdx
	sed -i 's/hyperindexformat{\\\(infn {[0-9]*\)}/\1/' thecorpusbook.adx
	sed -i 's/hyperindexformat{\\\(infn {[0-9]*\)}/\1/' thecorpusbook.ldx
# 	python3 fixindex.py
# 	mv mainmod.adx thecorpusbook.adx
	makeindex -o thecorpusbook.and thecorpusbook.adx
	makeindex -o thecorpusbook.lnd thecorpusbook.ldx
	makeindex -o thecorpusbook.snd thecorpusbook.sdx 
	xelatex thecorpusbook 
 

cover: FORCE
	convert thecorpusbook.pdf\[0\] -quality 100 -background white -alpha remove -bordercolor "#999999" -border 2  cover.png
	cp cover.png googlebooks_frontcover.png
	convert -geometry 50x50% cover.png covertwitter.png
	convert thecorpusbook.pdf\[0\] -quality 100 -background white -alpha remove -bordercolor "#999999" -border 2  -resize x495 coveromp.png
	display cover.png


googlebooks: googlebooks_interior.pdf

googlebooks_interior.pdf: complete
	cp thecorpusbook.pdf googlebooks_interior.pdf
	pdftk thecorpusbook.pdf cat 1 output googlebooks_frontcover.pdf 

openreview: openreview.pdf
	

openreview.pdf: thecorpusbook.pdf
	pdftk thecorpusbook.pdf multistamp orstamp.pdf output openreview.pdf 

proofreading: proofreading.pdf
	
paperhive: 
	git branch gh-pages
	git checkout gh-pages
	git add proofreading.pdf versions.json
	git commit -m 'prepare for proofreading' proofreading.pdf versions.json
	git push origin gh-pages
	git checkout master 
	echo "langsci.github.io/BOOKID"
	firefox https://paperhive.org/documents/new
	
proofreading.pdf: thecorpusbook.pdf
	pdftk thecorpusbook.pdf multistamp prstamp.pdf output proofreading.pdf 

blurb: blurb.html blurb.tex biosketch.tex biosketch.html


blurb.tex: blurb.md
	pandoc -f markdown -t latex blurb.md>blurb.tex
	
blurb.html: blurb.md
	pandoc -f markdown -t html blurb.md>blurb.html
	
biosketch.tex: blurb.md
	pandoc -f markdown -t latex biosketch.md>biosketch.tex
	
biosketch.html: blurb.md
	pandoc -f markdown -t html biosketch.md>biosketch.html
	
clean:
	rm -f *.bak *~ *.backup *.tmp \
	*.adx *.and *.idx *.ind *.ldx *.lnd *.sdx *.snd *.rdx *.rnd *.wdx *.wnd \
	*.log *.blg *.ilg \
	*.aux *.toc *.cut *.out *.tpm *.bbl *-blx.bib *_tmp.bib \
	*.glg *.glo *.gls *.wrd *.wdv *.xdv *.mw *.clr \
	*.run.xml thecorpusbook.tex thecorpusbook.pgs thecorpusbook.bcf \
	chapters/*aux chapters/*~ chapters/*.bak chapters/*.backup \
	langsci/*/*aux langsci/*/*~ langsci/*/*.bak langsci/*/*.backup \
	cache/* figures/* cache*.*
	
realclean: clean
	rm -f *.dvi *.ps *.pdf

chapterlist:
	grep chapter thecorpusbook.toc|sed "s/.*numberline {[0-9]\+}\(.*\).newline.*/\\1/" 

podcover:
	bash podcovers.sh

FORCE:
