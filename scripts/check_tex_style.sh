#!/usr/bin/env bash
set -euo pipefail

# Линтер исходников .tex.
# Цель: единый стиль и предсказуемая читаемость текста/блоков перед нормоконтролем.
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
  # Можно передать конкретные пути для точечной проверки.
  mapfile -t TEX_FILES < <(collect_files "$@")
else
  # По умолчанию проверяем контент и основной body.
  mapfile -t TEX_FILES < <(collect_files content thesis/document-body.tex)
fi

if (( ${#TEX_FILES[@]} == 0 )); then
  echo "ERROR: no TeX files found for style check." >&2
  exit 1
fi

status=0

# Запрещаем старый display-math синтаксис.
if search_fixed '$$' "${TEX_FILES[@]}"; then
  echo "ERROR: display math with \$\$...\$\$ is forbidden. Use equation/align/gather." >&2
  status=1
fi

if search_fixed '\\[' "${TEX_FILES[@]}"; then
  echo "ERROR: display math with \\\[ ... is forbidden. Use equation/align/gather." >&2
  status=1
fi

if search_fixed '\\]' "${TEX_FILES[@]}"; then
  echo "ERROR: display math with ... \\] is forbidden. Use equation/align/gather." >&2
  status=1
fi

for tex_file in "${TEX_FILES[@]}"; do
  # AWK-проход проверяет пустые строки вокруг блочных окружений.
  if ! awk '
    { lines[NR] = $0 }
    END {
      bad = 0
      for (i = 1; i <= NR; i++) {
        line = lines[i]
        if (line ~ /^[[:space:]]*\\begin\{(equation\*?|align\*?|gather\*?|multline\*?|figure\*?|table\*?|tikzpicture|lstlisting)\}/) {
          if (i > 1 && lines[i-1] !~ /^[[:space:]]*$/) {
            printf "%s:%d: missing blank line before block environment\n", FILENAME, i
            bad = 1
          }
        }

        if (line ~ /^[[:space:]]*\\end\{(equation\*?|align\*?|gather\*?|multline\*?|figure\*?|table\*?|tikzpicture|lstlisting)\}/) {
          if (i < NR && lines[i+1] !~ /^[[:space:]]*$/) {
            printf "%s:%d: missing blank line after block environment\n", FILENAME, i
            bad = 1
          }
        }
      }
      if (bad) {
        exit 1
      }
    }
  ' "$tex_file"; then
    status=1
  fi
done

if (( status != 0 )); then
  # Hard-fail: если стиль нарушен, сборку останавливаем.
  echo "ERROR: TeX style checks failed." >&2
  exit 1
fi

echo "TeX style check passed."
