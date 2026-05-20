#!/usr/bin/env bash
set -euo pipefail

# Скрипт проверяет, что в PDF реально встроены нужные семейства шрифтов.
# Это помогает избежать "съезда" верстки на другом компьютере.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/check_common.sh"

pdf="${1:-build/main.pdf}"
if [[ ! -f "$pdf" ]]; then
  check_rule_error \
    "FONT-000" \
    "Файл PDF не найден" \
    "Невозможно проверить шрифты, если итоговый PDF еще не собран." \
    "Сначала выполните сборку (make build или make build-matrix), затем повторите проверку." \
    $'make build DEGREE=bachelor\n./scripts/check_fonts.sh build/main-bachelor.pdf' \
    "make check-fonts" \
    "scripts/check_fonts.sh (правило FONT-000)" \
    "docs/checks-customization.md#font-rules"
  exit 1
fi

if ! command -v pdffonts >/dev/null 2>&1; then
  check_rule_error \
    "FONT-001" \
    "Не найдена утилита pdffonts" \
    "Без pdffonts нельзя прочитать список встроенных шрифтов из PDF." \
    "Установите poppler-utils (Linux) или пакет с утилитой pdffonts в вашей системе." \
    $'sudo apt-get update && sudo apt-get install -y poppler-utils' \
    "make check-fonts" \
    "scripts/check_fonts.sh (правило FONT-001)" \
    "docs/checks-customization.md#font-rules"
  exit 1
fi

fonts_report="$(pdffonts "$pdf")"
printf '%s\n' "$fonts_report"

status=0

if ! grep -Eiq 'PTAstraSerif|PT-Astra-Serif|AstraSerif' <<<"$fonts_report"; then
  check_rule_error \
    "FONT-101" \
    "В PDF не найден основной шрифт PT Astra Serif" \
    "Основной текст диплома должен быть на PT Astra Serif; иначе верстка может не соответствовать требованиям." \
    "Проверьте подключение PT Astra Serif в классе и наличие файлов в fonts/paratype." \
    $'Проверьте: thesis/sthg-vkr.cls\nПроверьте файлы: fonts/paratype/*.ttf' \
    "make check-fonts" \
    "scripts/check_fonts.sh (правило FONT-101)" \
    "docs/checks-customization.md#font-rules"
  status=1
fi

if ! grep -Eiq 'FiraCode|Fira' <<<"$fonts_report"; then
  check_rule_error \
    "FONT-102" \
    "В PDF не найден моноширинный шрифт Fira Code" \
    "Листинги должны рендериться на Fira Code для воспроизводимости примеров кода." \
    "Проверьте, что файлы Fira Code доступны локально и настроены в class-файле." \
    $'Проверьте: fonts/fira-code/*.ttf\nПроверьте настройки \\setmonofont в thesis/sthg-vkr.cls' \
    "make check-fonts" \
    "scripts/check_fonts.sh (правило FONT-102)" \
    "docs/checks-customization.md#font-rules"
  status=1
fi

if ! grep -Eiq 'STIXTwoMath|STIX' <<<"$fonts_report"; then
  check_rule_error \
    "FONT-103" \
    "В PDF не найден математический шрифт STIX Two Math" \
    "Без STIX формулы могут отличаться по метрикам и визуально от ожидаемого эталона." \
    "Проверьте подключение unicode-math и доступность файлов STIX Two Math." \
    $'Проверьте: fonts/stix-two-math/*.otf\nПроверьте настройки \\setmathfont в thesis/sthg-vkr.cls' \
    "make check-fonts" \
    "scripts/check_fonts.sh (правило FONT-103)" \
    "docs/checks-customization.md#font-rules"
  status=1
fi

if grep -Eiq 'Libertinus|Termes|TeXGyre' <<<"$fonts_report"; then
  check_rule_error \
    "FONT-104" \
    "Обнаружен legacy fallback-шрифт (Libertinus/TeX Gyre/Termes)" \
    "Fallback шрифты означают, что документ собран не в strict-local режиме и может выглядеть иначе на другом ПК." \
    "Уберите fallback на системные serif-шрифты и оставьте только локальные шрифты проекта." \
    $'Проверьте цепочки fallback в thesis/sthg-vkr.cls\nУбедитесь, что локальные файлы шрифтов существуют' \
    "make check-fonts" \
    "scripts/check_fonts.sh (правило FONT-104)" \
    "docs/checks-customization.md#font-rules"
  status=1
fi

if (( status != 0 )); then
  check_rule_ok "Font check завершился с ошибками. См. подсказки выше."
  exit 1
fi

check_rule_ok "Font check passed."
