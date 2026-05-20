#!/usr/bin/env bash
set -euo pipefail

pdf="${1:-build/main.pdf}"
if [[ ! -f "$pdf" ]]; then
  echo "ERROR: PDF not found: $pdf" >&2
  exit 1
fi
if ! command -v pdftotext >/dev/null 2>&1; then
  echo "ERROR: pdftotext is required for structure checks." >&2
  exit 1
fi

text_file="$(mktemp)"
trap 'rm -f "$text_file"' EXIT
pdftotext "$pdf" "$text_file"

required=(
  "Оглавление"
  "ВВЕДЕНИЕ"
  "Глава 1"
  "Глава 2"
  "ЗАКЛЮЧЕНИЕ"
  "Список используемых источников"
  "Пример приложения"
)

for token in "${required[@]}"; do
  if ! grep -Fq "$token" "$text_file"; then
    echo "ERROR: missing required section token: $token" >&2
    exit 1
  fi
done

echo "Structure check passed."
