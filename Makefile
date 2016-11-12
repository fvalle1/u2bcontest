#Makefile for uni2b

#Source

File= documento.pdf
dep= forest_graph.pdf p_quartiere.pdf

#Compiler

Latex=pdflatex
Bibtex=bibtex

#Dependencies
documento.pdf: documento.tex $(dep)

#Main rule
all: $(File)

%.pdf: %.tex
	$(Latex) $<
	$(Latex) $<
	$(Latex) $<
	make clean
	open $@

#clean
clean:
	rm -f *~ *.aux *.out *.log *.nav *.snm *.toc *.bbl *.blg

#	$(Bibtex) $(File:%.pdf=%)
#	$(Latex) $<
