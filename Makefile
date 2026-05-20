SHELL := bash

DEGREE ?= bachelor
PROFILE ?= rgpu-herzen
LANGUAGE ?= ru
ENTRY := main-$(DEGREE).tex
ENTRY_BASE := $(patsubst %.tex,%,$(ENTRY))
PDF := build/$(ENTRY_BASE).pdf
MATRIX_PDFS := build/main-bachelor.pdf build/main-specialist.pdf

.PHONY: help build watch clean distclean check check-fonts check-layout check-structure build-matrix

help:
	@echo "Targets:"
	@echo "  make build DEGREE=bachelor|specialist"
	@echo "  make watch DEGREE=bachelor|specialist"
	@echo "  make check"
	@echo "  make clean | distclean"

build:
	latexmk -interaction=nonstopmode -halt-on-error -file-line-error -lualatex $(ENTRY)
	cp -f "$(PDF)" build/main.pdf

watch:
	latexmk -interaction=nonstopmode -file-line-error -pvc -lualatex $(ENTRY)

build-matrix:
	$(MAKE) build DEGREE=bachelor
	$(MAKE) build DEGREE=specialist

check-fonts: build-matrix
	@for pdf in $(MATRIX_PDFS); do \
		./scripts/check_fonts.sh "$$pdf"; \
	done

check-layout: build-matrix
	./scripts/check_title_layout.sh "00-input-examples/Клементьев А.А. Дипломная работа.docx" build/main-bachelor.pdf

check-structure: build-matrix
	@for pdf in $(MATRIX_PDFS); do \
		./scripts/check_structure.sh "$$pdf"; \
	done

check: check-fonts check-layout check-structure

clean:
	latexmk -c main-bachelor.tex
	latexmk -c main-specialist.tex
	rm -f build/main.pdf

distclean:
	latexmk -C main-bachelor.tex
	latexmk -C main-specialist.tex
	rm -rf build/*
