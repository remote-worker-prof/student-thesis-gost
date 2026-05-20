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
make import-paratype-fonts
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
- Для импорта PT Astra Serif/Sans из архивов используйте `make import-paratype-fonts`.
- Системные serif fallback отключены намеренно для воспроизводимой сборки.

## License
- Основная лицензия проекта: [MIT](LICENSE).
- Copyright (c) 2026 Dmitry Vlasov.

## Third-party licenses
- Лицензии и атрибуции для шрифтов и изображений: [THIRD_PARTY_NOTICES.md](THIRD_PARTY_NOTICES.md).
