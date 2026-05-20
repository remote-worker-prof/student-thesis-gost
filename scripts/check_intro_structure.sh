#!/usr/bin/env bash
set -euo pipefail

# Hard-fail проверка структуры введения по эталонной схеме.
# Цель: не допускать дрейфа структуры и стилистики при следующих правках.

readonly INTRO_FILE="content/introduction.tex"
status=0
if command -v rg >/dev/null 2>&1; then
  HAS_RG=1
else
  HAS_RG=0
fi

search_fixed() {
  local needle="$1"
  if (( HAS_RG == 1 )); then
    rg -n -m1 -F "${needle}" "${INTRO_FILE}"
  else
    grep -n -m1 -F -- "${needle}" "${INTRO_FILE}"
  fi
}

search_fixed_all() {
  local needle="$1"
  if (( HAS_RG == 1 )); then
    rg -n -F "${needle}" "${INTRO_FILE}"
  else
    grep -n -F -- "${needle}" "${INTRO_FILE}"
  fi
}

if [[ ! -f "${INTRO_FILE}" ]]; then
  echo "ERROR: introduction file not found: ${INTRO_FILE}" >&2
  exit 1
fi

find_line() {
  local needle="$1"
  search_fixed "${needle}" | cut -d: -f1
}

# 1) Запрещаем ссылки и inline-выделения во введении.
for forbidden in '\autocite' '\texttt{' '\textbf{' '\textit{'; do
  if search_fixed_all "${forbidden}"; then
    echo "ERROR: forbidden token in introduction: ${forbidden}" >&2
    status=1
  fi
done

# 2) Проверяем наличие ключевых блоков.
line_actuality="$(find_line 'Таким образом, актуальность данной темы обусловлена противоречием' || true)"
line_significance="$(find_line 'Разработка системы, которая включает технологии интеллектуального анализа' || true)"
line_goal="$(find_line 'Целью настоящего исследования является' || true)"
line_tasks_intro="$(find_line 'Для достижения поставленной цели были сформулированы следующие задачи:' || true)"
line_structure="$(find_line 'Структура выпускной квалификационной работы соответствует поставленным задачам' || true)"

for block in line_actuality line_significance line_goal line_tasks_intro line_structure; do
  if [[ -z "${!block}" ]]; then
    echo "ERROR: required introduction block is missing: ${block}" >&2
    status=1
  fi
done

# 3) Проверяем порядок ключевых блоков.
if [[ -n "${line_actuality}" && -n "${line_significance}" && -n "${line_goal}" \
   && -n "${line_tasks_intro}" && -n "${line_structure}" ]]; then
  if ! (( line_actuality < line_significance && line_significance < line_goal \
       && line_goal < line_tasks_intro && line_tasks_intro < line_structure )); then
    echo "ERROR: introduction blocks are out of required order." >&2
    status=1
  fi
fi

# 4) Проверяем наличие нумерованного списка задач и его позицию.
line_enum_begin="$(find_line '\begin{enumerate}' || true)"
line_enum_end="$(find_line '\end{enumerate}' || true)"
if [[ -z "${line_enum_begin}" || -z "${line_enum_end}" ]]; then
  echo "ERROR: enumerate block for tasks is missing." >&2
  status=1
elif [[ -n "${line_tasks_intro}" && -n "${line_structure}" ]]; then
  if ! (( line_tasks_intro < line_enum_begin && line_enum_end < line_structure )); then
    echo "ERROR: enumerate block is not placed between tasks intro and structure block." >&2
    status=1
  fi
fi

# 5) Проверяем, что задач ровно 4 и пунктуация ; ; ; .
mapfile -t ITEM_LINES < <(
  awk '
    /\\begin{enumerate}/ { inside = 1; next }
    /\\end{enumerate}/   { inside = 0 }
    inside && /^[[:space:]]*\\item[[:space:]]+/ { print }
  ' "${INTRO_FILE}"
)

if (( ${#ITEM_LINES[@]} != 4 )); then
  echo "ERROR: expected 4 tasks in introduction enumerate, got ${#ITEM_LINES[@]}." >&2
  status=1
else
  for idx in 0 1 2; do
    if [[ ! "${ITEM_LINES[idx]}" =~ \;[[:space:]]*$ ]]; then
      echo "ERROR: task $((idx + 1)) must end with ';'." >&2
      status=1
    fi
  done
  if [[ ! "${ITEM_LINES[3]}" =~ \.[[:space:]]*$ ]]; then
    echo "ERROR: task 4 must end with '.'." >&2
    status=1
  fi
fi

if (( status != 0 )); then
  echo "ERROR: introduction structure check failed." >&2
  exit 1
fi

echo "Introduction structure check passed."
