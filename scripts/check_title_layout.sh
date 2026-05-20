#!/usr/bin/env bash
set -euo pipefail

# Скрипт сравнивает геометрию титульного листа с эталонным DOCX.
# Используется приближенная метрика RMSE по растровым изображениям первой страницы.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/check_common.sh"

ref_docx="${1:?Usage: check_title_layout.sh <reference.docx> <target.pdf>}"
target_pdf="${2:?Usage: check_title_layout.sh <reference.docx> <target.pdf>}"

missing=()
for cmd in soffice identify awk; do
  command -v "$cmd" >/dev/null 2>&1 || missing+=("$cmd")
done

have_magick=0
if command -v magick >/dev/null 2>&1; then
  have_magick=1
else
  for cmd in convert compare; do
    command -v "$cmd" >/dev/null 2>&1 || missing+=("$cmd")
  done
fi

if (( ${#missing[@]} > 0 )); then
  if [[ "${STRICT_LAYOUT_CHECK:-0}" == "1" ]]; then
    check_rule_error \
      "LAYOUT-001" \
      "Не хватает утилит для проверки геометрии титула" \
      "При STRICT_LAYOUT_CHECK=1 проверка обязана выполняться полностью, иначе возможен неконтролируемый дрейф титульного листа." \
      "Установите недостающие утилиты и повторите запуск." \
      "Недостающие команды: ${missing[*]}" \
      "make check-layout" \
      "scripts/check_title_layout.sh (правило LAYOUT-001)" \
      "docs/checks-customization.md#layout-rules"
    exit 1
  fi

  check_rule_warning \
    "LAYOUT-001" \
    "Проверка геометрии титула пропущена" \
    "Не найдены команды: ${missing[*]}. В нестрогом режиме это предупреждение, а не ошибка." \
    "Для обязательной проверки установите зависимости и/или задайте STRICT_LAYOUT_CHECK=1." \
    "scripts/check_title_layout.sh (правило LAYOUT-001)" \
    "docs/checks-customization.md#layout-rules"
  exit 0
fi

workdir="$(mktemp -d)"
trap 'rm -rf "$workdir"' EXIT

soffice --headless --convert-to pdf --outdir "$workdir" "$ref_docx" >/dev/null 2>&1
ref_pdf="$(find "$workdir" -maxdepth 1 -name '*.pdf' | head -n1)"
if [[ -z "$ref_pdf" ]]; then
  check_rule_error \
    "LAYOUT-002" \
    "Не удалось конвертировать эталонный DOCX в PDF" \
    "Без PDF-версии эталона нельзя посчитать метрику RMSE и сравнить титул." \
    "Проверьте путь к эталонному DOCX и корректность установки LibreOffice." \
    "Проверьте файл: ${ref_docx}" \
    "make check-layout" \
    "scripts/check_title_layout.sh (правило LAYOUT-002)" \
    "docs/checks-customization.md#layout-rules"
  exit 1
fi

if (( have_magick == 1 )); then
  magick -density 180 "$ref_pdf[0]" -colorspace Gray -trim +repage "$workdir/ref.png"
  magick -density 180 "$target_pdf[0]" -colorspace Gray -trim +repage "$workdir/target.png"
else
  convert -density 180 "$ref_pdf[0]" -colorspace Gray -trim +repage "$workdir/ref.png"
  convert -density 180 "$target_pdf[0]" -colorspace Gray -trim +repage "$workdir/target.png"
fi

size="$(identify -format '%wx%h' "$workdir/ref.png")"
if (( have_magick == 1 )); then
  magick "$workdir/target.png" -resize "${size}!" "$workdir/target_resized.png"
  metric_raw="$(magick compare -metric RMSE "$workdir/ref.png" "$workdir/target_resized.png" null: 2>&1 || true)"
else
  convert "$workdir/target.png" -resize "${size}!" "$workdir/target_resized.png"
  metric_raw="$(compare -metric RMSE "$workdir/ref.png" "$workdir/target_resized.png" null: 2>&1 || true)"
fi

rmse="$(awk -F'[()]' '{print $2}' <<<"$metric_raw")"
threshold="0.38"

if [[ -z "$rmse" ]]; then
  check_rule_error \
    "LAYOUT-003" \
    "Не удалось вычислить RMSE для титульного листа" \
    "Без RMSE невозможно автоматически понять, насколько титульник отклонился от эталона." \
    "Проверьте, что целевой PDF корректен и первая страница содержит титул." \
    "Проверьте входные файлы: ${ref_docx} и ${target_pdf}" \
    "make check-layout" \
    "scripts/check_title_layout.sh (правило LAYOUT-003)" \
    "docs/checks-customization.md#layout-rules"
  exit 1
fi

printf 'Title layout RMSE: %s (threshold <= %s)\n' "$rmse" "$threshold"
if ! awk -v r="$rmse" -v t="$threshold" 'BEGIN { exit (r <= t ? 0 : 1) }'; then
  check_rule_error \
    "LAYOUT-004" \
    "Геометрия титульного листа вышла за допустимый порог" \
    "Значимое отклонение RMSE обычно означает, что блоки титула съехали относительно эталона." \
    "Проверьте вертикальные отступы, позиции логотипа и правого блока, затем пересоберите PDF." \
    "Текущий RMSE: ${rmse}; допустимый порог: ${threshold}" \
    "make check-layout" \
    "scripts/check_title_layout.sh (правило LAYOUT-004)" \
    "docs/checks-customization.md#layout-rules"
  exit 1
fi

check_rule_ok "Title layout check passed."
