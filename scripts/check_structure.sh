#!/usr/bin/env bash
set -euo pipefail

# Проверяем, что в итоговом PDF присутствуют обязательные разделы ВКР.
# Скрипт не проверяет качество текста, только факт наличия ключевых токенов.
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

# Минимальный набор разделов для этого шаблона.
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
    # Ошибка сразу валит check, чтобы проблему заметили до предзащиты.
    echo "ERROR: missing required section token: $token" >&2
    exit 1
  fi
done

echo "Structure check passed."
