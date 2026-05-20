#!/usr/bin/env bash
set -euo pipefail

# Проверяем, что в итоговом PDF присутствуют обязательные разделы ВКР.
# Скрипт не проверяет качество текста, только факт наличия ключевых токенов.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/check_common.sh"

pdf="${1:-build/main.pdf}"
if [[ ! -f "$pdf" ]]; then
  check_rule_error \
    "STRUCT-000" \
    "Файл PDF не найден" \
    "Проверка структуры работает только по уже собранному итоговому документу." \
    "Сначала соберите PDF и передайте корректный путь в скрипт." \
    $'make build DEGREE=bachelor\n./scripts/check_structure.sh build/main-bachelor.pdf' \
    "make check-structure" \
    "scripts/check_structure.sh (правило STRUCT-000)" \
    "docs/checks-customization.md#structure-rules"
  exit 1
fi

if ! command -v pdftotext >/dev/null 2>&1; then
  check_rule_error \
    "STRUCT-001" \
    "Не найдена утилита pdftotext" \
    "Без pdftotext скрипт не может извлечь текст из PDF и проверить разделы." \
    "Установите poppler-utils или аналогичный пакет с pdftotext." \
    $'sudo apt-get update && sudo apt-get install -y poppler-utils' \
    "make check-structure" \
    "scripts/check_structure.sh (правило STRUCT-001)" \
    "docs/checks-customization.md#structure-rules"
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

missing=()
for token in "${required[@]}"; do
  if ! grep -Fq "$token" "$text_file"; then
    missing+=("$token")
  fi
done

if (( ${#missing[@]} > 0 )); then
  {
    echo "В PDF отсутствуют обязательные разделы:"
    for token in "${missing[@]}"; do
      echo "- ${token}"
    done
  } >&2

  check_rule_error \
    "STRUCT-101" \
    "Не найдены обязательные разделы ВКР" \
    "Если хотя бы один обязательный раздел отсутствует, документ может не пройти нормоконтроль." \
    "Проверьте подключение разделов в основном документе и наличие заголовков в соответствующих .tex-файлах." \
    $'Проверьте: thesis/document-body.tex\nПроверьте заголовки глав и приложений в content/*.tex' \
    "make check-structure" \
    "scripts/check_structure.sh (правило STRUCT-101)" \
    "docs/checks-customization.md#structure-rules"
  exit 1
fi

check_rule_ok "Structure check passed."
