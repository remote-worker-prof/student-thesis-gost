#!/usr/bin/env bash
set -euo pipefail

# Hard-fail проверка структуры введения по эталонной схеме.
# Цель: не допускать дрейфа структуры и стилистики при следующих правках.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/check_common.sh"

readonly INTRO_FILE="content/introduction.tex"
status=0

if command -v rg >/dev/null 2>&1; then
  HAS_RG=1
else
  HAS_RG=0
fi

search_first() {
  local needle="$1"
  if (( HAS_RG == 1 )); then
    rg -n -m1 -F "${needle}" "${INTRO_FILE}"
  else
    grep -n -m1 -F -- "${needle}" "${INTRO_FILE}"
  fi
}

search_all() {
  local needle="$1"
  if (( HAS_RG == 1 )); then
    rg -n -F "${needle}" "${INTRO_FILE}"
  else
    grep -n -F -- "${needle}" "${INTRO_FILE}"
  fi
}

find_line() {
  local needle="$1"
  search_first "${needle}" | cut -d: -f1
}

if [[ ! -f "${INTRO_FILE}" ]]; then
  check_rule_error \
    "INTRO-000" \
    "Файл введения не найден" \
    "Проверка структуры введения невозможна без файла content/introduction.tex." \
    "Восстановите файл введения или проверьте путь в скрипте." \
    "ls -la content/introduction.tex" \
    "make check-intro-structure" \
    "scripts/check_intro_structure.sh (правило INTRO-000)" \
    "docs/checks-customization.md#intro-rules"
  exit 1
fi

forbidden_found=0
forbidden_patterns=(
  '\autocite'
  '\texttt{'
  '\textbf{'
  '\textit{'
)

forbidden_labels=(
  'команда цитирования \\autocite'
  'моноширинное выделение \\texttt{...}'
  'жирное выделение \\textbf{...}'
  'курсивное выделение \\textit{...}'
)

for idx in "${!forbidden_patterns[@]}"; do
  matches="$(search_all "${forbidden_patterns[idx]}" || true)"
  if [[ -n "${matches}" ]]; then
    printf '%s\n' "${matches}" >&2
    printf '%s\n' "${INTRO_FILE}: найден запрещенный элемент: ${forbidden_labels[idx]}" >&2
    forbidden_found=1
  fi
done

if (( forbidden_found == 1 )); then
  check_rule_error \
    "INTRO-001" \
    "Во введении найдены запрещенные inline-выделения или ссылки" \
    "По эталонной схеме введение должно быть единым narrative-блоком без inline-разметки и ссылочных команд." \
    "Удалите \\autocite, \\texttt, \\textbf, \\textit из введения и перенесите акценты в главы." \
    $'Неверно: \\textbf{Актуальность} ... \\autocite{...}\nВерно: Актуальность темы определяется ...' \
    "make check-intro-structure" \
    "scripts/check_intro_structure.sh (правило INTRO-001)" \
    "docs/checks-customization.md#intro-rules"
  status=1
fi

block_titles=(
  'Блок актуальности через противоречие'
  'Блок значимости и эффекта решения'
  'Блок формулировки цели исследования'
  'Фраза-ввод к списку задач'
  'Финальный блок о структуре работы'
)

block_needles=(
  'Таким образом, актуальность данной темы обусловлена противоречием'
  'Разработка системы, которая включает технологии интеллектуального анализа'
  'Целью настоящего исследования является'
  'Для достижения поставленной цели были сформулированы следующие задачи:'
  'Структура выпускной квалификационной работы соответствует поставленным задачам'
)

block_lines=()
missing_blocks=0
for idx in "${!block_needles[@]}"; do
  line="$(find_line "${block_needles[idx]}" || true)"
  block_lines+=("${line}")
  if [[ -z "${line}" ]]; then
    printf '%s\n' "${INTRO_FILE}: отсутствует обязательный блок: ${block_titles[idx]}" >&2
    missing_blocks=1
  fi
done

if (( missing_blocks == 1 )); then
  check_rule_error \
    "INTRO-002" \
    "Во введении отсутствуют обязательные смысловые блоки" \
    "Структура введения должна жестко соответствовать эталону, иначе проверка не может подтвердить нормативный формат." \
    "Добавьте отсутствующие блоки в требуемой формулировочной зоне (актуальность, значимость, цель, задачи, структура)." \
    $'Минимальная последовательность:\n1) Актуальность\n2) Значимость\n3) Цель\n4) Фраза перед задачами\n5) Список задач\n6) Структура работы' \
    "make check-intro-structure" \
    "scripts/check_intro_structure.sh (правило INTRO-002)" \
    "docs/checks-customization.md#intro-rules"
  status=1
fi

if (( missing_blocks == 0 )); then
  if ! (( block_lines[0] < block_lines[1] && block_lines[1] < block_lines[2] && block_lines[2] < block_lines[3] && block_lines[3] < block_lines[4] )); then
    printf '%s\n' "${INTRO_FILE}: нарушен порядок блоков введения (актуальность -> значимость -> цель -> задачи -> структура)." >&2
    check_rule_error \
      "INTRO-003" \
      "Нарушен порядок обязательных блоков введения" \
      "Даже при наличии всех абзацев порядок влияет на соответствие эталонной композиции введения." \
      "Переставьте абзацы так, чтобы сначала шли актуальность и значимость, затем цель, задачи и структура." \
      $'Правильно: ... цель исследования ...\nДля достижения поставленной цели ...\n\\begin{enumerate} ... \\end{enumerate}\nСтруктура выпускной квалификационной работы ...' \
      "make check-intro-structure" \
      "scripts/check_intro_structure.sh (правило INTRO-003)" \
      "docs/checks-customization.md#intro-rules"
    status=1
  fi
fi

line_enum_begin="$(find_line '\begin{enumerate}' || true)"
line_enum_end="$(find_line '\end{enumerate}' || true)"

if [[ -z "${line_enum_begin}" || -z "${line_enum_end}" ]]; then
  printf '%s\n' "${INTRO_FILE}: отсутствует нумерованный список задач (окружение enumerate)." >&2
  check_rule_error \
    "INTRO-004" \
    "Не найден нумерованный список задач" \
    "Эталон требует явный список задач исследования; без enumerate нарушается структура введения." \
    "Добавьте окружение enumerate сразу после фразы о задачах." \
    $'Для достижения поставленной цели были сформулированы следующие задачи:\n\\begin{enumerate}\n  \\item ...;\n  \\item ...;\n  \\item ...;\n  \\item ....\n\\end{enumerate}' \
    "make check-intro-structure" \
    "scripts/check_intro_structure.sh (правило INTRO-004)" \
    "docs/checks-customization.md#intro-rules"
  status=1
elif (( missing_blocks == 0 )); then
  if ! (( block_lines[3] < line_enum_begin && line_enum_end < block_lines[4] )); then
    printf '%s\n' "${INTRO_FILE}: список задач должен быть расположен между вводной фразой о задачах и финальным абзацем о структуре работы." >&2
    check_rule_error \
      "INTRO-005" \
      "Список задач стоит не на своем месте" \
      "Положение списка задач фиксировано эталоном и проверяется отдельно от общего порядка абзацев." \
      "Переместите enumerate между фразой о задачах и блоком о структуре ВКР." \
      $'... Для достижения поставленной цели ...\n\\begin{enumerate}\n  \\item ...\n\\end{enumerate}\nСтруктура выпускной квалификационной работы ...' \
      "make check-intro-structure" \
      "scripts/check_intro_structure.sh (правило INTRO-005)" \
      "docs/checks-customization.md#intro-rules"
    status=1
  fi
fi

mapfile -t ITEM_LINES < <(
  awk '
    /\\begin{enumerate}/ { inside = 1; next }
    /\\end{enumerate}/   { inside = 0 }
    inside && /^[[:space:]]*\\item[[:space:]]+/ { print }
  ' "${INTRO_FILE}"
)

if (( ${#ITEM_LINES[@]} != 4 )); then
  printf '%s\n' "${INTRO_FILE}: в списке задач должно быть ровно 4 пункта, сейчас: ${#ITEM_LINES[@]}." >&2
  check_rule_error \
    "INTRO-006" \
    "Некорректное количество задач во введении" \
    "Эталонный формат фиксирует 4 задачи для этой версии шаблона." \
    "Оставьте ровно четыре пункта в enumerate." \
    $'\\begin{enumerate}\n  \\item ...;\n  \\item ...;\n  \\item ...;\n  \\item ....\n\\end{enumerate}' \
    "make check-intro-structure" \
    "scripts/check_intro_structure.sh (правило INTRO-006)" \
    "docs/checks-customization.md#intro-rules"
  status=1
elif (( ${#ITEM_LINES[@]} == 4 )); then
  punctuation_error=0
  for idx in 0 1 2; do
    if [[ ! "${ITEM_LINES[idx]}" =~ \;[[:space:]]*$ ]]; then
      printf '%s\n' "${INTRO_FILE}: пункт задачи $((idx + 1)) должен заканчиваться ';'" >&2
      punctuation_error=1
    fi
  done
  if [[ ! "${ITEM_LINES[3]}" =~ \.[[:space:]]*$ ]]; then
    printf '%s\n' "${INTRO_FILE}: пункт задачи 4 должен заканчиваться '.'" >&2
    punctuation_error=1
  fi

  if (( punctuation_error == 1 )); then
    check_rule_error \
      "INTRO-007" \
      "Нарушена пунктуация в списке задач введения" \
      "Пунктуация ; ; ; . проверяется как часть эталонной композиции введения." \
      "Исправьте окончания пунктов: первые три на ';', последний на '.'." \
      $'\\item Провести анализ предметной области;\n\\item Сформировать архитектуру решения;\n\\item Реализовать прототип системы;\n\\item Оценить результаты эксперимента.' \
      "make check-intro-structure" \
      "scripts/check_intro_structure.sh (правило INTRO-007)" \
      "docs/checks-customization.md#intro-rules"
    status=1
  fi
fi

if (( status != 0 )); then
  check_rule_ok "Introduction structure check завершился с ошибками. См. подсказки выше."
  exit 1
fi

check_rule_ok "Introduction structure check passed."
