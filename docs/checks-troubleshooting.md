# Troubleshooting: проверки шаблона ВКР

Этот документ расшифровывает коды ошибок из `make check` и помогает быстро
понять, что исправлять в исходниках диплома.

## Как читать код ошибки
- Пример: `STYLE-004`.
- Префикс (`STYLE`, `INTRO`, `FONT`, `STRUCT`, `LAYOUT`) показывает тип проверки.
- Число показывает конкретное правило внутри проверки.

## Таблица правил

| Код | Что проверяется | Типовая причина | Что исправить | Как перепроверить |
|---|---|---|---|---|
| `STYLE-000` | Найдены ли `.tex` файлы для style-check | Скрипт запущен не из корня проекта или неверные пути | Передайте корректные пути или запускайте `make check-style` из корня | `make check-style` |
| `STYLE-001` | Запрет `$$...$$` | Старый LaTeX-синтаксис формул | Замените на `equation/align/gather` | `make check-style` |
| `STYLE-002` | Запрет `\[` | Формула оформлена через `\[` | Замените на `equation/align/gather` | `make check-style` |
| `STYLE-003` | Запрет `\]` | Закрытие старого display-math блока | Переведите формулу в окружение `equation/align/gather` | `make check-style` |
| `STYLE-004` | Пустые строки вокруг блочных окружений | Нет пустой строки до/после `\begin{...}` или `\end{...}` | Добавьте пустые строки вокруг формул, рисунков, таблиц, TikZ и листингов | `make check-style` |
| `INTRO-000` | Наличие `content/introduction.tex` | Файл удален, переименован или перемещен | Верните файл или поправьте путь в скрипте | `make check-intro-structure` |
| `INTRO-001` | Запрет inline-элементов во введении | Во введении есть `\autocite`, `\texttt`, `\textbf`, `\textit` | Уберите эти команды из введения | `make check-intro-structure` |
| `INTRO-002` | Обязательные блоки введения | Отсутствует один из смысловых абзацев | Добавьте недостающий блок (актуальность/значимость/цель/задачи/структура) | `make check-intro-structure` |
| `INTRO-003` | Порядок блоков введения | Абзацы стоят не в эталонной последовательности | Переставьте абзацы в требуемом порядке | `make check-intro-structure` |
| `INTRO-004` | Наличие `enumerate` для задач | Список задач не оформлен как нумерованный | Добавьте `\begin{enumerate} ... \end{enumerate}` | `make check-intro-structure` |
| `INTRO-005` | Позиция списка задач | `enumerate` стоит не между нужными блоками | Переместите список задач в корректное место | `make check-intro-structure` |
| `INTRO-006` | Количество задач | В списке не 4 пункта | Оставьте ровно 4 задачи | `make check-intro-structure` |
| `INTRO-007` | Пунктуация задач | У первых трех пунктов не `;`, у четвертого не `.` | Исправьте окончания пунктов в списке задач | `make check-intro-structure` |
| `FONT-000` | Наличие PDF для проверки шрифтов | Документ не собран или путь неверный | Сначала соберите PDF | `make check-fonts` |
| `FONT-001` | Наличие `pdffonts` | Нет poppler-utils в системе | Установите `pdffonts` (обычно пакет `poppler-utils`) | `make check-fonts` |
| `FONT-101` | Встроен PT Astra Serif | Основной шрифт не подхватился | Проверьте настройки `\setmainfont` и файлы `fonts/paratype` | `make check-fonts` |
| `FONT-102` | Встроен Fira Code | Листинговый шрифт не встроен | Проверьте `\setmonofont` и наличие Fira Code | `make check-fonts` |
| `FONT-103` | Встроен STIX Two Math | Математический шрифт не встроен | Проверьте `\setmathfont` и наличие STIX Two Math | `make check-fonts` |
| `FONT-104` | Нет legacy fallback serif | Сработал fallback на Libertinus/TeX Gyre/Termes | Уберите системные fallback serif в классе | `make check-fonts` |
| `STRUCT-000` | Наличие PDF для проверки структуры | Нет целевого PDF | Сначала выполните сборку | `make check-structure` |
| `STRUCT-001` | Наличие `pdftotext` | Нет poppler-utils в системе | Установите `pdftotext` | `make check-structure` |
| `STRUCT-101` | Обязательные разделы в PDF | Пропущены главы/разделы/приложение | Проверьте подключение разделов в `thesis/document-body.tex` и `content/*.tex` | `make check-structure` |
| `LAYOUT-001` | Утилиты для проверки титула | Отсутствуют `soffice`/ImageMagick/awk | Установите зависимости; при строгом режиме это hard-fail | `make check-layout` |
| `LAYOUT-002` | Конвертация эталонного DOCX | LibreOffice не смог сделать PDF-эталон | Проверьте путь к DOCX и работоспособность `soffice` | `make check-layout` |
| `LAYOUT-003` | Расчет RMSE | Не удалось получить метрику сравнения | Проверьте входные файлы и первую страницу целевого PDF | `make check-layout` |
| `LAYOUT-004` | Порог RMSE титула | Титульный лист сильно отклонен от эталона | Исправьте геометрию титула (блоки, отступы, логотип) | `make check-layout` |

## Быстрые команды для студента
```bash
make check-help
make check-style
make check-intro-structure
make check
```

## Где менять правила
Если вы делаете собственный форк и хотите изменить строгость проверок, сначала
прочитайте:
- `docs/checks-customization.md`
