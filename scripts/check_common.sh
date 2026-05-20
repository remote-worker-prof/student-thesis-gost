#!/usr/bin/env bash
set -euo pipefail

# Общие функции учебных сообщений для hard-fail проверок.
# Эти функции дают студенту не только факт ошибки, но и понятный путь к исправлению.

readonly CHECKS_TROUBLESHOOTING_DOC="docs/checks-troubleshooting.md"
readonly CHECKS_CUSTOMIZATION_DOC="docs/checks-customization.md"

_check_print_block() {
  local text="$1"
  while IFS= read -r line; do
    printf '  %s\n' "$line" >&2
  done <<<"$text"
}

check_rule_error() {
  local code="$1"
  local title="$2"
  local why="$3"
  local fix="$4"
  local example="$5"
  local rerun="$6"
  local where_rule="$7"
  local where_customize="$8"

  {
    echo ""
    echo "ERROR [${code}] ${title}"
    echo "Почему это важно: ${why}"
    echo "Что исправить: ${fix}"
    if [[ -n "${example}" ]]; then
      echo "Мини-пример исправления:"
    fi
  } >&2

  if [[ -n "${example}" ]]; then
    _check_print_block "${example}"
  fi

  {
    echo "Проверить снова: ${rerun}"
    echo "Где смотреть правило: ${where_rule}"
    echo "Подробный разбор: ${CHECKS_TROUBLESHOOTING_DOC} (код: ${code})"
    echo "Как изменить в своем форке: ${where_customize}"
    echo ""
  } >&2
}

check_rule_warning() {
  local code="$1"
  local title="$2"
  local explanation="$3"
  local action="$4"
  local where_rule="$5"
  local where_customize="$6"

  {
    echo ""
    echo "WARN  [${code}] ${title}"
    echo "Что произошло: ${explanation}"
    echo "Что можно сделать: ${action}"
    echo "Где смотреть правило: ${where_rule}"
    echo "Подробный разбор: ${CHECKS_TROUBLESHOOTING_DOC} (код: ${code})"
    echo "Как изменить в своем форке: ${where_customize}"
    echo ""
  } >&2
}

check_rule_ok() {
  local message="$1"
  printf '%s\n' "${message}"
}
