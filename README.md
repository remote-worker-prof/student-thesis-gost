# student-thesis-gost

Production-ready LuaLaTeX-шаблон ВКР под профиль `rgpu-herzen` с параметрами:
- `degree=bachelor|specialist`
- `profile=rgpu-herzen`
- `language=ru`

Шаблон ориентирован на практику нормоконтроля: точный титульный лист по эталонному DOCX + нормализованный основной текст и библиография в стиле ГОСТ.

## Что включено
- Класс [`thesis/sthg-vkr.cls`](thesis/sthg-vkr.cls) с опциями профиля/уровня.
- Единая точка метаданных [`config/metadata.tex`](config/metadata.tex).
- Каркас ВКР: титул, содержание, введение, главы, заключение, литература, приложения.
- Библиография `biblatex-gost + biber` через [`bibliography/sources.bib`](bibliography/sources.bib).
- Bundled open-source шрифты в `fonts/`:
  - serif: PT Astra Serif (Paratype, primary),
  - sans: PT Astra Sans (дополнительная family),
  - mono: Fira Code,
  - math: STIX Two Math.
- Локальные проверки: структура PDF, шрифты, регрессия титульника.
- CI-сборка PDF и публикация артефактов.

## Быстрый старт

```bash
make format-content-80
make check-help
make build DEGREE=bachelor
make build DEGREE=specialist
make watch DEGREE=bachelor
make check
make clean
```

`make check` выполняет:
1. matrix-сборку (`bachelor`, `specialist`),
2. проверку встроенных шрифтов,
3. проверку структуры разделов,
4. визуальную регрессию титульного листа относительно
   `00-input-examples/Клементьев А.А. Дипломная работа.docx`.

Проверки и подсказки по ним:
- `make check-help` — краткий каталог всех проверок и их назначение.
- `docs/checks-troubleshooting.md` — расшифровка кодов ошибок и примеры исправлений.
- `docs/checks-customization.md` — где и как безопасно менять правила в своем форке.

## Требования окружения
- `lualatex`, `latexmk`, `biber`
- `pdffonts`, `pdftotext` (из `poppler-utils`)
- для `check-layout`: `libreoffice` + `imagemagick`

## Структура проекта
- [`main-bachelor.tex`](main-bachelor.tex), [`main-specialist.tex`](main-specialist.tex) — профильные входы.
- [`main.tex`](main.tex) — дефолтный алиас на `main-bachelor.tex`.
- [`thesis/document-body.tex`](thesis/document-body.tex) — общий корпус документа.
- [`config/metadata.tex`](config/metadata.tex) — все титульные/служебные поля.
- [`thesis/sthg-vkr.cls`](thesis/sthg-vkr.cls) — класс и правила оформления.
- `content/` — текст разделов.
- `bibliography/` — bib-данные.
- `scripts/` — проверки PDF.
- `docs/` — нормативная матрица, иерархия правил, R&D-реестр.

## Нормативный контур
- Иерархия требований: ГОСТ-база → профиль РГПУ → локальные инженерные фиксы.
- Конфликты разрешаются по правилу:
  - титульник: геометрия эталонного DOCX,
  - основной текст: нормализованные параметры профиля/ГОСТ,
  - шрифты: open-source и воспроизводимость.

## Политика шрифтов
- Класс использует strict-local настройку `fontspec`: обязательные файлы шрифтов должны быть в репозитории.
- Системные serif fallback отключены намеренно для воспроизводимой сборки.

### Как обновлять шрифты в своем форке
1. Замените файлы нужного семейства напрямую в `fonts/` (с сохранением имен файлов, которые использует класс).
2. Проверьте, что лицензии/атрибуции актуальны в `THIRD_PARTY_NOTICES.md`.
3. Запустите `make check-fonts`, затем `make check`.

## Форматирование текста (80 символов)
- Команда `make format-content-80` форматирует только `content/*.tex`.
- Ограничение `80` применяется к narrative-прозе; технические конструкции LaTeX и verbatim-блоки не режутся принудительно.
- Основа: `latexindent` (обычно доступен в TeX Live/MiKTeX).
- Upstream: https://github.com/cmhughes/latexindent.pl

## Проверки и кастомизация в форках
- Все hard-fail проверки используют единый учебный формат сообщений с кодами правил (`STYLE-*`, `INTRO-*`, `FONT-*`, `STRUCT-*`, `LAYOUT-*`).
- Быстрый обзор правил: `make check-help`.
- Подробные разборы ошибок: `docs/checks-troubleshooting.md`.
- Точки безопасной кастомизации в форке: `docs/checks-customization.md`.

## License
- Основная лицензия проекта: [MIT](LICENSE).
- Copyright (c) 2026 Dmitry Vlasov.

## Third-party licenses
- Лицензии и атрибуции для шрифтов и изображений: [THIRD_PARTY_NOTICES.md](THIRD_PARTY_NOTICES.md).
