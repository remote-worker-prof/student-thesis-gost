# Bundled Fonts

В проект включены open-source шрифты для воспроизводимой LuaLaTeX-сборки.

## Serif (основной текст)
- Семейство: Libertinus Serif (primary)
- Файлы: `fonts/libertinus/LibertinusSerif-*.otf`
- Источник: https://mirrors.ctan.org/fonts/libertinus-fonts/otf/
- Лицензия: SIL Open Font License 1.1

## Serif fallback
- Семейство: TeX Gyre Termes
- Файлы: `fonts/texgyre/*.otf`
- Источник: https://mirrors.ctan.org/fonts/tex-gyre/opentype/
- Лицензия: GUST Font License (GFL)

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
- в классе задан fallback на системные аналоги, если bundled-файлы недоступны.
