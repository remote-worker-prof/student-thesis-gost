# Подписи и таблицы по ГОСТ в шаблоне ВКР

Краткий учебный документ для студентов: какие правила приняты в шаблоне и где их
менять в своем форке.

## Принятые правила в этом репозитории
- `figure`: подпись снизу, формат `Рисунок N — Наименование`.
- `table`: подпись сверху, формат `Таблица N — Наименование`, выравнивание
  подписи по левому краю.
- `lstlisting`: формат подписи `Листинг N — Наименование` (единый разделитель
  с рисунками).
- Кегль подписей `figure/table/lstlisting`: как у основного текста
  (`normalsize`, serif).
- Табличные примеры в шаблоне: не менее 6, из них не менее 2 в приложениях.

## Что проверяется автоматически
- `make check-caption-policy`:
  - `lstlisting` использует `labelsep=emdash`;
  - `table` использует `position=top`, `labelsep=emdash`,
    `justification=raggedright`, `singlelinecheck=false`;
  - в `content/*.tex` есть минимум 6 таблиц, в `content/appendix-*.tex` минимум
    2 таблицы.

## Где менять в форке
- Политика подписей: `thesis/sthg-vkr.cls`
- Hard-fail проверка: `scripts/check_caption_policy.sh`
- Включение в общий pipeline: `Makefile` (`make check`)

## Нормативные ориентиры
- ГОСТ 7.32-2017 (иллюстрации и таблицы, разделы 6.5 и 6.6):  
  https://www.imp.uran.ru/sites/default/files/upload/mezhgosudarstvennyy_standart_gost_7.32-2017_sistema_standartov_po_informacii_bi-1_26.10.2018.pdf
- ГОСТ Р 2.105-2019 (таблицы и графический материал, разделы 6.8 и 6.9):  
  https://guap.ru/standards/db/docs/GOST_R_2.105-2019.pdf

Примечание: локальная методичка кафедры/вуза имеет приоритет над общим
проектным профилем, если есть официальное расхождение требований.
