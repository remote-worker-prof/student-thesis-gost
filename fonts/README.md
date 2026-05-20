# Bundled Fonts

В проект включены open-source шрифты для воспроизводимой LuaLaTeX-сборки.

## Serif (основной текст)
- Семейство: PT Astra Serif (Paratype, primary)
- Файлы: `fonts/paratype/pt-astra-serif_*.ttf`
- Источник импорта: архивы из `PARATYPE_ARCHIVE_DIR` (по умолчанию `/home/sorcerer/Downloads/Fonts/Paratype`) через `make import-paratype-fonts`
- Лицензия: SIL Open Font License 1.1

## Sans (дополнительная family)
- Семейство: PT Astra Sans
- Файлы: `fonts/paratype/pt-astra-sans_*.ttf`
- Назначение: дополнительная `fontspec`-family (`\ParatypeSans`) и `\setsansfont`
- Лицензия: SIL Open Font License 1.1

## Mono (код)
- Семейство: Fira Code
- Файлы: `fonts/firacode/FiraCode-Regular.ttf`, `fonts/firacode/FiraCode-Bold.ttf`
- Источник: https://cdn.jsdelivr.net/npm/firacode@6.2.0/distr/ttf/
- Репозиторий: https://github.com/tonsky/FiraCode
- Лицензия: SIL Open Font License 1.1

## Math (формулы)
- Семейство: STIX Two Math
- Файл: `fonts/stix/STIXTwoMath-Regular.otf`
- Источник: https://mirrors.ctan.org/fonts/stix2-otf/
- Лицензия: SIL Open Font License 1.1

## Принцип выбора
- шрифты включены в репозиторий для стабильной сборки в локальной среде и CI,
- используется strict-local политика: при отсутствии обязательных файлов сборка прерывается `\ClassError`.
