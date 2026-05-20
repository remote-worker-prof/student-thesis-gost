SHELL := bash

# Параметры сборки.
# DEGREE меняйте на bachelor/specialist в зависимости от типа ВКР.
DEGREE ?= bachelor
PROFILE ?= rgpu-herzen
LANGUAGE ?= ru
ENTRY := main-$(DEGREE).tex
ENTRY_BASE := $(patsubst %.tex,%,$(ENTRY))
PDF := build/$(ENTRY_BASE).pdf
MATRIX_PDFS := build/main-bachelor.pdf build/main-specialist.pdf

.PHONY: help build watch clean distclean check check-style check-fonts check-layout check-structure build-matrix import-paratype-fonts format-content-80

help:
	@echo "Основные команды для студента:"
	@echo "Targets:"
	@echo "  make build DEGREE=bachelor|specialist"
	@echo "  make watch DEGREE=bachelor|specialist"
	@echo "  make import-paratype-fonts"
	@echo "  make format-content-80"
	@echo "  make check"
	@echo "  make clean | distclean"

import-paratype-fonts:
	# Импорт PT Astra из локальных архивов (см. scripts/import_paratype_fonts.sh).
	./scripts/import_paratype_fonts.sh

format-content-80:
	# Форматирование narrative-текста диплома в content/*.tex до 80 символов.
	./scripts/format_content_tex.sh

build:
	# Обычная сборка выбранного профиля.
	latexmk -interaction=nonstopmode -halt-on-error -file-line-error -lualatex $(ENTRY)
	cp -f "$(PDF)" build/main.pdf

watch:
	# Непрерывная сборка при изменении исходников.
	latexmk -interaction=nonstopmode -file-line-error -pvc -lualatex $(ENTRY)

build-matrix:
	# Проверочная сборка обеих версий документа.
	$(MAKE) build DEGREE=bachelor
	$(MAKE) build DEGREE=specialist

check-style:
	# Линтер TeX-стиля: запрет $$ и \[...\], пустые строки вокруг блоков.
	./scripts/check_tex_style.sh

check-fonts: build-matrix
	# Проверка встроенных шрифтов в итоговых PDF.
	@for pdf in $(MATRIX_PDFS); do \
		./scripts/check_fonts.sh "$$pdf"; \
	done

check-layout: build-matrix
	# Сравнение титула с эталонным DOCX через RMSE.
	./scripts/check_title_layout.sh "00-input-examples/Клементьев А.А. Дипломная работа.docx" build/main-bachelor.pdf

check-structure: build-matrix
	# Проверка наличия обязательных разделов в тексте PDF.
	@for pdf in $(MATRIX_PDFS); do \
		./scripts/check_structure.sh "$$pdf"; \
	done

# Полный набор обязательных проверок перед push.
check: check-style check-fonts check-layout check-structure

clean:
	# Удаление промежуточных TeX-артефактов.
	latexmk -c main-bachelor.tex
	latexmk -c main-specialist.tex
	rm -f build/main.pdf

distclean:
	# Полная очистка build/ и вспомогательных файлов.
	latexmk -C main-bachelor.tex
	latexmk -C main-specialist.tex
	rm -rf build/*
