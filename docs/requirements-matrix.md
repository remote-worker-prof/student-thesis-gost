# Нормативная матрица требований

Дата фиксации: 2026-05-20.

## Иерархия
1. ГОСТ-база и федеральные нормы.
2. Профиль РГПУ (`rgpu-herzen`) и локальные документы ГИА.
3. Локальные инженерные решения шаблона для воспроизводимости LuaLaTeX.

## Матрица требований

| Блок | Требование в шаблоне | Источник | Решение/приоритет |
|---|---|---|---|
| Формат листа | A4 (210x297 мм) | [ГОСТ 7.32-2017](https://www.gasu.ru/science/otdel-nti/gosudarstvennaya-registratsiya-nioktr/gost_7.32_2017.pdf) | `critical`: фиксировано в классе |
| Поля | левое 30 мм, правое 15 мм, верх/низ 20 мм | [РГПУ: требования к тексту ВКР](https://physics.herzen.spb.ru/students/gia/vrk-text-requirements/) | `critical`: baseline профиля |
| Межстрочный | 1.5 | [РГПУ: требования к тексту ВКР](https://physics.herzen.spb.ru/students/gia/vrk-text-requirements/) | `high` |
| Абзац | 1.25 см | [РГПУ: требования к тексту ВКР](https://physics.herzen.spb.ru/students/gia/vrk-text-requirements/) | `high` |
| Выравнивание | по ширине | [РГПУ: требования к тексту ВКР](https://physics.herzen.spb.ru/students/gia/vrk-text-requirements/) | `high` |
| Структура рукописи | титул, содержание, введение, основная часть, заключение, источники, приложения | [ГОСТ 7.32-2017](https://www.gasu.ru/science/otdel-nti/gosudarstvennaya-registratsiya-nioktr/gost_7.32_2017.pdf), [РГПУ: требования к тексту ВКР](https://physics.herzen.spb.ru/students/gia/vrk-text-requirements/) | `high` |
| Нумерация страниц | сквозная, титул в счете, номер на титуле скрыт | [РГПУ: требования к тексту ВКР](https://physics.herzen.spb.ru/students/gia/vrk-text-requirements/) | `high` |
| Титульный лист | геометрия и порядок блоков воспроизводятся по эталону DOCX | `00-input-examples/Клементьев А.А. Дипломная работа.docx` | `critical`: практический эталон |
| Библиография | `biblatex-gost + biber` | [CTAN: biblatex-gost](https://ctan.org/recommendations/gost), [ГОСТ Р 7.0.5-2008](https://www.nntu.ru/frontend/web/ngtu/files/org_structura/library/resurvsy/gost_r_7_0_5_2008.pdf), [ГОСТ Р 7.0.100-2018](https://physics.herzen.spb.ru/students/gia/vrk-text-requirements/) | `high` |
| Шрифты | только open-source, bundled в репозитории | проектная политика | `high` |

## Зафиксированные конфликты и развязка
- В части подразделений РГПУ встречается локальный вариант полей `25/10/20/20` (например, презентационные материалы ГИА по институту). Для базового профиля шаблона принят публичный baseline `30/15/20/20` с официальной страницы требований.
- В Word-образце встречаются стилевые артефакты (смешение шрифтов и служебных стилей). Они не переносятся в LuaLaTeX-шаблон.
- При расхождении текстовых рекомендаций и эталонного DOCX применяется правило: титульник по геометрии эталона, основной корпус по нормализованным правилам профиля.

## Используемые параметры в классе
- `geometry`: `left=30mm,right=15mm,top=20mm,bottom=20mm`
- `setspace`: `1.5`
- `parindent`: `1.25cm`
- `degree`: `bachelor|specialist`
- `profile`: `rgpu-herzen`
- `language`: `ru`
