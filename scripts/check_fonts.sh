#!/usr/bin/env bash
set -euo pipefail

# Скрипт проверяет, что в PDF реально встроены нужные семейства шрифтов.
# Это помогает избежать "съезда" верстки на другом компьютере.
pdf="${1:-build/main.pdf}"
if [[ ! -f "$pdf" ]]; then
  echo "ERROR: PDF not found: $pdf" >&2
  exit 1
fi
if ! command -v pdffonts >/dev/null 2>&1; then
  echo "ERROR: pdffonts is required for font checks." >&2
  exit 1
fi

fonts_report="$(pdffonts "$pdf")"
echo "$fonts_report"

# Основной текст должен быть на PT Astra Serif.
grep -Eiq 'PTAstraSerif|PT-Astra-Serif|AstraSerif' <<<"$fonts_report" || { echo "ERROR: Serif font (PT Astra Serif) not embedded." >&2; exit 1; }
# Листинги должны быть на Fira Code.
grep -Eiq 'FiraCode|Fira' <<<"$fonts_report" || { echo "ERROR: Monospace font (Fira Code) not embedded." >&2; exit 1; }
# Формулы должны быть на STIX Two Math.
grep -Eiq 'STIXTwoMath|STIX' <<<"$fonts_report" || { echo "ERROR: Math font (STIX Two Math) not embedded." >&2; exit 1; }
# Запрещаем старые fallback-шрифты, чтобы не было "тихого" отката.
if grep -Eiq 'Libertinus|Termes|TeXGyre' <<<"$fonts_report"; then
  echo "ERROR: Legacy serif fallback detected (Libertinus/TeX Gyre)." >&2
  exit 1
fi

echo "Font check passed."
