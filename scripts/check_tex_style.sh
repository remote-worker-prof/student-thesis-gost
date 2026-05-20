#!/usr/bin/env bash
set -euo pipefail

collect_files() {
  local -a roots=("$@")
  local -a found=()
  local root
  for root in "${roots[@]}"; do
    if [[ -d "$root" ]]; then
      while IFS= read -r f; do
        found+=("$f")
      done < <(rg --files "$root" -g '*.tex')
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
  echo "ERROR: no TeX files found for style check." >&2
  exit 1
fi

status=0

if rg -n -F '$$' "${TEX_FILES[@]}"; then
  echo "ERROR: display math with \$\$...\$\$ is forbidden. Use equation/align/gather." >&2
  status=1
fi

if rg -n -F '\\[' "${TEX_FILES[@]}"; then
  echo "ERROR: display math with \\\[ ... is forbidden. Use equation/align/gather." >&2
  status=1
fi

if rg -n -F '\\]' "${TEX_FILES[@]}"; then
  echo "ERROR: display math with ... \\] is forbidden. Use equation/align/gather." >&2
  status=1
fi

for tex_file in "${TEX_FILES[@]}"; do
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
  echo "ERROR: TeX style checks failed." >&2
  exit 1
fi

echo "TeX style check passed."
