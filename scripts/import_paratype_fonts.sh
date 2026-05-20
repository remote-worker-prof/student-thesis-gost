#!/usr/bin/env bash
set -euo pipefail

# Импорт локальных архивов Paratype в репозиторий.
# Нужен для воспроизводимой сборки без системных font fallback.
SRC_DIR="${PARATYPE_ARCHIVE_DIR:-/home/sorcerer/Downloads/Fonts/Paratype}"
DEST_DIR="fonts/paratype"

if [[ ! -d "$SRC_DIR" ]]; then
  echo "ERROR: Source directory not found: $SRC_DIR" >&2
  echo "Set PARATYPE_ARCHIVE_DIR to the folder with Paratype zip archives." >&2
  exit 1
fi

if ! command -v unzip >/dev/null 2>&1; then
  echo "ERROR: unzip is required." >&2
  exit 1
fi

mapfile -t ZIP_FILES < <(find "$SRC_DIR" -maxdepth 1 -type f -name '*.zip' | sort)
if (( ${#ZIP_FILES[@]} == 0 )); then
  echo "ERROR: No zip archives found in: $SRC_DIR" >&2
  exit 1
fi

tmp_dir="$(mktemp -d)"
trap 'rm -rf "$tmp_dir"' EXIT

# Распаковка архивов и перенос только TTF файлов.
mkdir -p "$DEST_DIR"

for zip_file in "${ZIP_FILES[@]}"; do
  unzip -q -o "$zip_file" -d "$tmp_dir/$(basename "${zip_file%.zip}")"
done

mapfile -t TTF_FILES < <(find "$tmp_dir" -type f -iname '*.ttf' | sort)
if (( ${#TTF_FILES[@]} == 0 )); then
  echo "ERROR: No .ttf files found in extracted archives." >&2
  exit 1
fi

for ttf_file in "${TTF_FILES[@]}"; do
  cp -f "$ttf_file" "$DEST_DIR/$(basename "$ttf_file")"
done

OFL_FILE="$(find "$tmp_dir" -type f -name 'OFL.txt' | head -n1 || true)"
if [[ -n "$OFL_FILE" ]]; then
  # Кладем лицензию рядом со шрифтами для юридической прозрачности.
  cp -f "$OFL_FILE" "$DEST_DIR/OFL.txt"
fi

required_files=(
  "pt-astra-serif_regular.ttf"
  "pt-astra-serif_bold.ttf"
  "pt-astra-serif_italic.ttf"
  "pt-astra-serif_bold-italic.ttf"
  "pt-astra-sans_regular.ttf"
  "pt-astra-sans_bold.ttf"
  "pt-astra-sans_italic.ttf"
  "pt-astra-sans_bold-italic.ttf"
)

missing=0
for required in "${required_files[@]}"; do
  if [[ ! -f "$DEST_DIR/$required" ]]; then
    echo "ERROR: Missing required font file after import: $DEST_DIR/$required" >&2
    missing=1
  fi
done

if (( missing != 0 )); then
  # Останавливаемся, если набор неполный: strict-local policy в классе потребует все файлы.
  exit 1
fi

echo "Imported Paratype fonts to $DEST_DIR"
ls -1 "$DEST_DIR"
