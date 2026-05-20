#!/usr/bin/env bash
set -euo pipefail

# Скрипт сравнивает геометрию титульного листа с эталонным DOCX.
# Используется приближенная метрика RMSE по растровым изображениям первой страницы.
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
  # В CI можно сделать проверку обязательной через STRICT_LAYOUT_CHECK=1.
  if [[ "${STRICT_LAYOUT_CHECK:-0}" == "1" ]]; then
    echo "ERROR: missing commands: ${missing[*]}" >&2
    exit 1
  fi
  echo "WARN: skipping title layout check; missing commands: ${missing[*]}"
  exit 0
fi

workdir="$(mktemp -d)"
trap 'rm -rf "$workdir"' EXIT

# Конвертируем DOCX в PDF и берем первую страницу как референс.
soffice --headless --convert-to pdf --outdir "$workdir" "$ref_docx" >/dev/null 2>&1
ref_pdf="$(find "$workdir" -maxdepth 1 -name '*.pdf' | head -n1)"
[[ -n "$ref_pdf" ]] || { echo "ERROR: failed to convert DOCX reference to PDF" >&2; exit 1; }

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
# Порог выбран эмпирически под текущий эталон титула.
threshold="0.38"

echo "Title layout RMSE: $rmse (threshold <= $threshold)"
awk -v r="$rmse" -v t="$threshold" 'BEGIN { exit (r <= t ? 0 : 1) }' || {
  echo "ERROR: title page layout drift exceeds threshold." >&2
  exit 1
}

echo "Title layout check passed."
