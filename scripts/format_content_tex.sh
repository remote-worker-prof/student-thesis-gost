#!/usr/bin/env bash
set -euo pipefail

# Форматтер narrative-текста ВКР:
# - обрабатывает только content/*.tex;
# - переносит русскую прозу к 80 символам через latexindent;
# - не ломает verbatim/lstlisting благодаря профилю в YAML.

readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly REPO_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
readonly CONFIG_FILE="${SCRIPT_DIR}/latexindent-content.yaml"
readonly CRUFT_DIR="${REPO_ROOT}/build/latexindent-cruft"
readonly UPSTREAM_URL="https://github.com/cmhughes/latexindent.pl"

if ! command -v latexindent >/dev/null 2>&1; then
  echo "ERROR: latexindent not found. Install TeX Live/MiKTeX latexindent package." >&2
  echo "Upstream: ${UPSTREAM_URL}" >&2
  exit 1
fi

if [[ ! -f "${CONFIG_FILE}" ]]; then
  echo "ERROR: formatter config not found: ${CONFIG_FILE}" >&2
  exit 1
fi

mkdir -p "${CRUFT_DIR}"

mapfile -t TEX_FILES < <(cd "${REPO_ROOT}" && rg --files content -g '*.tex' | sort)

if (( ${#TEX_FILES[@]} == 0 )); then
  echo "ERROR: no TeX files found in content/." >&2
  exit 1
fi

for rel_path in "${TEX_FILES[@]}"; do
  echo "Formatting ${rel_path}"
  latexindent -m -wd -l="${CONFIG_FILE}" -c "${CRUFT_DIR}" \
    "${REPO_ROOT}/${rel_path}" >/dev/null
done

# Чистим служебные артефакты latexindent, чтобы build/ не засорялся.
find "${CRUFT_DIR}" -mindepth 1 -delete

echo "Done. Formatted ${#TEX_FILES[@]} file(s) in content/."
