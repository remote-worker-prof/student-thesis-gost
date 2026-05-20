#!/usr/bin/env bash
set -euo pipefail

cat <<'OUT'
Каталог проверок дипломного шаблона

1) Исходники TeX
- make check-style
- Скрипт: scripts/check_tex_style.sh
- Назначение: запрет устаревших display-math конструкций и контроль пустых строк вокруг блоков.

2) Структура введения
- make check-intro-structure
- Скрипт: scripts/check_intro_structure.sh
- Назначение: hard-fail контроль обязательной композиции введения по эталонной схеме.

3) Шрифты PDF
- make check-fonts
- Скрипт: scripts/check_fonts.sh
- Назначение: проверка встроенных PT Astra Serif, Fira Code и STIX Two Math.

4) Геометрия титульного листа
- make check-layout
- Скрипт: scripts/check_title_layout.sh
- Назначение: сравнение первой страницы с эталонным DOCX по RMSE.

5) Структура итогового PDF
- make check-structure
- Скрипт: scripts/check_structure.sh
- Назначение: наличие обязательных разделов ВКР в финальном документе.

Сводный запуск
- make check

Где читать правила и как менять под форк
- docs/checks-troubleshooting.md
- docs/checks-customization.md
OUT
