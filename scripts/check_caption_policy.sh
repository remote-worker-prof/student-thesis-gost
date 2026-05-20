#!/usr/bin/env bash
set -euo pipefail

# Hard-fail проверка политики подписей и минимального табличного наполнения.
# Цель: стабилизировать ГОСТ-формат подписей и учебную полноту примеров таблиц.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/check_common.sh"

CLASS_FILE="thesis/sthg-vkr.cls"
status=0

if [[ ! -f "$CLASS_FILE" ]]; then
  check_rule_error \
    "CAPTION-000" \
    "Не найден файл класса шаблона" \
    "Без класса невозможно проверить политику подписей figure/table/listing." \
    "Проверьте путь к файлу класса или запускайте проверку из корня репозитория." \
    "Файл должен существовать: thesis/sthg-vkr.cls" \
    "make check-caption-policy" \
    "scripts/check_caption_policy.sh (правило CAPTION-000)" \
    "docs/checks-customization.md#caption-rules"
  exit 1
fi

lst_line="$(grep -F '\captionsetup[lstlisting]' "$CLASS_FILE" || true)"
if [[ -z "$lst_line" || "$lst_line" != *"labelsep=emdash"* ]]; then
  check_rule_error \
    "CAPTION-101" \
    "Подписи листингов должны использовать длинное тире" \
    "Единый формат подписей облегчает нормоконтроль и делает шаблон предсказуемым для студентов." \
    "Укажите для lstlisting параметр labelsep=emdash." \
    "\\captionsetup[lstlisting]{...,labelsep=emdash}" \
    "make check-caption-policy" \
    "scripts/check_caption_policy.sh (правило CAPTION-101)" \
    "docs/checks-customization.md#caption-rules"
  status=1
fi

table_line="$(grep -F '\captionsetup[table]' "$CLASS_FILE" || true)"
if [[ -z "$table_line" || "$table_line" != *"position=top"* || "$table_line" != *"labelsep=emdash"* || "$table_line" != *"justification=raggedright"* || "$table_line" != *"singlelinecheck=false"* ]]; then
  check_rule_error \
    "CAPTION-102" \
    "Подписи таблиц должны быть в ГОСТ-режиме (top + left + emdash)" \
    "Для таблиц ГОСТ требует наименование сверху, а левое выравнивание повышает читаемость длинных заголовков." \
    "Настройте table-caption: position=top, labelsep=emdash, justification=raggedright, singlelinecheck=false." \
    "\\captionsetup[table]{position=top,labelsep=emdash,justification=raggedright,singlelinecheck=false}" \
    "make check-caption-policy" \
    "scripts/check_caption_policy.sh (правило CAPTION-102)" \
    "docs/checks-customization.md#caption-rules"
  status=1
fi

if command -v rg >/dev/null 2>&1; then
  total_tables="$(rg -n -F '\begin{table}' content/*.tex 2>/dev/null | wc -l | tr -d ' ')"
  appendix_tables="$(rg -n -F '\begin{table}' content/appendix-*.tex 2>/dev/null | wc -l | tr -d ' ')"
else
  total_tables="$(grep -R -n --include='*.tex' '\\begin{table}' content 2>/dev/null | wc -l | tr -d ' ')"
  appendix_tables="$(grep -n '\\begin{table}' content/appendix-*.tex 2>/dev/null | wc -l | tr -d ' ')"
fi

if (( total_tables < 6 )); then
  check_rule_error \
    "CAPTION-201" \
    "Недостаточно учебных примеров таблиц в проекте" \
    "Шаблон должен показывать студентам несколько типовых ГОСТ-таблиц из основной части и приложений." \
    "Добавьте таблицы так, чтобы суммарно в content/*.tex было не менее 6 таблиц." \
    "Минимум: 6 таблиц в content/*.tex" \
    "make check-caption-policy" \
    "scripts/check_caption_policy.sh (правило CAPTION-201)" \
    "docs/checks-customization.md#caption-rules"
  status=1
fi

if (( appendix_tables < 2 )); then
  check_rule_error \
    "CAPTION-202" \
    "Недостаточно табличных примеров в приложениях" \
    "Приложение должно содержать минимум два табличных примера для демонстрации расширенных материалов." \
    "Добавьте в файлы content/appendix-*.tex минимум 2 окружения table." \
    "Минимум: 2 таблицы в content/appendix-*.tex" \
    "make check-caption-policy" \
    "scripts/check_caption_policy.sh (правило CAPTION-202)" \
    "docs/checks-customization.md#caption-rules"
  status=1
fi

if (( status != 0 )); then
  check_rule_ok "Caption policy check завершился с ошибками. См. подсказки выше."
  exit 1
fi

check_rule_ok "Caption policy check passed."
