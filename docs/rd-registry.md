# R&D-реестр источников (2024-2026)

Дата фиксации: 2026-05-20.

Реестр разделен по назначению: нормативные решения, инженерные референсы шаблонов и свежий контекстный контент. Нормативные решения принимаются только по источникам с высоким доверием.

## 1) Официальные и нормативные источники

| Источник | URL | Роль в проекте | Доверие |
|---|---|---|---|
| ГОСТ 7.32-2017 (текст стандарта, копия с вузовского сайта) | https://www.gasu.ru/science/otdel-nti/gosudarstvennaya-registratsiya-nioktr/gost_7.32_2017.pdf | Базовые параметры структуры/оформления | Высокий |
| ГОСТ Р 7.0.5-2008 (библиографические ссылки) | https://www.nntu.ru/frontend/web/ngtu/files/org_structura/library/resurvsy/gost_r_7_0_5_2008.pdf | Логика ссылок и ссылочных записей | Высокий |
| РГПУ: Государственная итоговая аттестация | https://www.herzen.spb.ru/students/gosudarstvennaya-itogovaya-attestatsiya/ | Нормативный контур университета, документы ГИА | Высокий |
| РГПУ: Требования к оформлению текста ВКР | https://physics.herzen.spb.ru/students/gia/vrk-text-requirements/ | Профильные параметры страниц, структуры и нумерации | Высокий |
| Приказ Минобрнауки РФ №636 (по ссылке РГПУ) | https://www.herzen.spb.ru/upload/medialibrary/076/Prikaz-Minobrnauki-Rossii-ot-29_06_2015-N-636-_red_-ot-27_03.pdf | Правовая рамка ГИА (бакалавриат/специалитет/магистратура) | Высокий |
| Положение о ГИА в РГПУ (редакция 20.02.2023) | https://www.herzen.spb.ru/upload/medialibrary/577/a4nxx4m71l5q4b5slb3dv35y2xqqbkc2/Polozhenie-o-GIA_novoe_20.02.2023.pdf | Локальный нормативный контур вуза | Высокий |

## 2) GitHub-референсы LaTeX-шаблонов

Данные по активности зафиксированы через GitHub API на 2026-05-20.

| Репозиторий | URL | `updated_at` | Что изучалось | Доверие |
|---|---|---|---|---|
| `AndreyAkinshin/Russian-Phd-LaTeX-Dissertation-Template` | https://github.com/AndreyAkinshin/Russian-Phd-LaTeX-Dissertation-Template | 2026-05-18 | зрелая архитектура русскоязычного thesis-template, практики сборки/структуры | Высокий |
| `zibliclub/bachelor-thesis` | https://github.com/zibliclub/bachelor-thesis | 2026-05-19 | свежий LuaLaTeX-каркас, разбиение контента и сборка | Средний |
| `AndreyLychev/MISIS-thesis` | https://github.com/AndreyLychev/MISIS-thesis | 2026-05-09 | вузовый шаблон и подходы к служебным элементам | Средний |
| `KernelA/xelatex-gost-bac` | https://github.com/KernelA/xelatex-gost-bac | 2026-01-05 | практики ГОСТ-оформления для выпускных работ | Средний |

## 3) Инструментальные источники (MCP Context7)

| Компонент | Источник | Что использовано | Доверие |
|---|---|---|---|
| `latexmk` | `/debian-tex/latexmk` | режимы LuaLaTeX, `-pvc`, `out_dir/aux_dir`, clean-экстеншены | Высокий |
| `fontspec` | `/latex3/fontspec` | загрузка шрифтов по filename+Path, fallback через `\IfFontExistsTF` | Высокий |
| `unicode-math` | `/latex3/unicode-math` | настройка `\setmathfont` для OTF math-font (STIX Two Math) | Высокий |

## 4) Свежие статьи 2024-2026 (контекст, не норматив)

Используются только как практический UX-контекст и чек-листы типичных ошибок.

| Материал | URL | Дата (по источнику) | Применение | Доверие |
|---|---|---|---|---|
| GostDoc: «Оформление ВКР по ГОСТ в 2026 году» | https://gostdoc.ru/blog/oformlenie-vkr-po-gost-2026/ | 2026-04-11 | частые ошибки и структура проверок | Низкий |
| Diplox: «Оформление ВКР по ГОСТу: полное руководство 2026» | https://diplox.online/blog/oformlenie-vkr-po-gostu | 2026-03-22 (обновлено 2026-04-17) | практический чек-лист перед сдачей | Низкий |
| Fenix Help: «Требования ГОСТа к оформлению ВКР в 2026» | https://blog.fenix.help/oformlenie-rabot/trebovaniya-gosta-k-oformleniyu-vkr | обновлено 2025-12-30 | сравнение трактовок и типовых допущений | Низкий |
| Praktika-studenta: «Как написать и оформить дипломную работу и ВКР в 2024» | https://praktika-studenta.ru/vkr/ | 2024-05-07 | ориентир по workflow подготовки | Низкий |

## 5) Политика принятия решений
- Нормативные параметры шаблона фиксируются только по официальным/институциональным источникам.
- GitHub-репозитории используются как инженерные референсы, а не как норматив.
- Контентные статьи 2024-2026 применяются только как вспомогательный список типичных ошибок.
