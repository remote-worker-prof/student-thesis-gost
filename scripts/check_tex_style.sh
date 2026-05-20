#!/usr/bin/env bash
set -euo pipefail

# Линтер исходников .tex.
# Цель: единый стиль и предсказуемая читаемость текста/блоков перед нормоконтролем.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/check_common.sh"

if command -v rg >/dev/null 2>&1; then
  HAS_RG=1
else
  HAS_RG=0
fi

collect_tex_files_from_dir() {
  local root="$1"
  if (( HAS_RG == 1 )); then
    rg --files "$root" -g '*.tex'
  else
    find "$root" -type f -name '*.tex'
  fi
}

search_fixed() {
  local needle="$1"
  shift
  if (( HAS_RG == 1 )); then
    rg -n -F "$needle" "$@"
  else
    grep -n -F -- "$needle" "$@"
  fi
}

collect_files() {
  local -a roots=("$@")
  local -a found=()
  local root
  for root in "${roots[@]}"; do
    if [[ -d "$root" ]]; then
      while IFS= read -r f; do
        found+=("$f")
      done < <(collect_tex_files_from_dir "$root")
    elif [[ -f "$root" ]]; then
      found+=("$root")
    fi
  done

  if (( ${#found[@]} == 0 )); then
    return 1
  fi

  printf '%s\n' "${found[@]}" | sort -u
}

if (( $# > 0 )); then
  mapfile -t TEX_FILES < <(collect_files "$@")
else
  mapfile -t TEX_FILES < <(collect_files content thesis/document-body.tex)
fi

if (( ${#TEX_FILES[@]} == 0 )); then
  check_rule_error \
    "STYLE-000" \
    "Не найдены TeX-файлы для style-check" \
    "Проверка не может оценить форматирование, если нет входных файлов." \
    "Укажите пути к .tex вручную или убедитесь, что есть директория content/ и файл thesis/document-body.tex." \
    "./scripts/check_tex_style.sh content thesis/document-body.tex" \
    "make check-style" \
    "scripts/check_tex_style.sh (правило STYLE-000)" \
    "docs/checks-customization.md#style-rules"
  exit 1
fi

status=0

check_forbidden_pattern() {
  local code="$1"
  local pattern="$2"
  local title="$3"
  local fix="$4"
  local example="$5"

  local matches
  matches="$(search_fixed "$pattern" "${TEX_FILES[@]}" || true)"
  if [[ -n "$matches" ]]; then
    printf '%s\n' "$matches" >&2
    check_rule_error \
      "$code" \
      "$title" \
      "Старые display-math конструкции ухудшают совместимость и ломают единый стиль диплома." \
      "$fix" \
      "$example" \
      "make check-style" \
      "scripts/check_tex_style.sh (правило ${code})" \
      "docs/checks-customization.md#style-rules"
    status=1
  fi
}

check_forbidden_pattern \
  "STYLE-001" \
  '$$' \
  "Найден запрещенный синтаксис display-math: \$\$...\$\$" \
  "Замените блоковую формулу на окружение equation/align/gather с нумерацией." \
  $'\\begin{equation}\nE = mc^2\n\\end{equation}'

check_forbidden_pattern \
  "STYLE-002" \
  '\[' \
  "Найден запрещенный синтаксис display-math: \\[ ..." \
  "Используйте нумеруемые окружения equation/align/gather вместо \\[ ... \\]." \
  $'\\begin{align}\ny &= ax + b \\\\ \nz &= cx + d\n\\end{align}'

check_forbidden_pattern \
  "STYLE-003" \
  '\]' \
  "Найден запрещенный синтаксис display-math: ... \\]" \
  "Преобразуйте формулу в окружение equation/align/gather и удалите закрывающий \\]." \
  $'\\begin{equation}\n\\int_0^1 x^2\\,dx = \\frac{1}{3}\n\\end{equation}'

spacing_violations=""
for tex_file in "${TEX_FILES[@]}"; do
  awk_output="$(awk '
    { lines[NR] = $0 }
    END {
      bad = 0
      for (i = 1; i <= NR; i++) {
        line = lines[i]

        if (line ~ /^[[:space:]]*\\begin\{(equation\*?|align\*?|gather\*?|multline\*?|figure\*?|table\*?|tikzpicture|lstlisting)\}/) {
          if (i > 1 && lines[i-1] !~ /^[[:space:]]*$/) {
            printf "%s:%d: STYLE-004: добавьте пустую строку перед блочным окружением\\n", FILENAME, i
            bad = 1
          }
        }

        if (line ~ /^[[:space:]]*\\end\{(equation\*?|align\*?|gather\*?|multline\*?|figure\*?|table\*?|tikzpicture|lstlisting)\}/) {
          if (i < NR && lines[i+1] !~ /^[[:space:]]*$/) {
            printf "%s:%d: STYLE-004: добавьте пустую строку после блочного окружения\\n", FILENAME, i
            bad = 1
          }
        }
      }
      if (bad) {
        exit 1
      }
    }
  ' "$tex_file" || true)"

  if [[ -n "$awk_output" ]]; then
    spacing_violations+="$awk_output"$'\n'
    status=1
  fi
done

if [[ -n "$spacing_violations" ]]; then
  printf '%s' "$spacing_violations" >&2
  check_rule_error \
    "STYLE-004" \
    "Нарушены пустые строки вокруг блочных окружений" \
    "Без пустых строк формулы, рисунки, таблицы и листинги тяжело читать и сопровождать." \
    "Добавьте по одной пустой строке перед \\begin{...} и после \\end{...} для всех блочных окружений." \
    $'Текст перед блоком.\n\n\\begin{figure}\n  ...\n\\end{figure}\n\nТекст после блока.' \
    "make check-style" \
    "scripts/check_tex_style.sh (правило STYLE-004)" \
    "docs/checks-customization.md#style-rules"
fi

if (( status != 0 )); then
  check_rule_ok "TeX style check завершился с ошибками. См. подсказки выше."
  exit 1
fi

check_rule_ok "TeX style check passed."
