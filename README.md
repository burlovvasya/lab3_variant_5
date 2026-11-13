# ЛР-3. Аналитический дашборд для бизнес-кейса — вариант 5

**Студент:** Бурлов В. Т. · **группа:** БД-251м
**Бизнес-кейс:** Корзина заказа: размер и состав

## Цель работы
Сколько товаров и продавцов в одном заказе? Как размер корзины связан со средним чеком и долей доставки?

## Исследуемые метрики
- **Средний чек** = `AVG([order_value])`
- **Товаров в заказе** = `SUM([items_cnt]) / COUNT([order_id])`
- **Доля доставки** = `SUM([freight_value]) / SUM([order_value])`

## Архитектура решения
Kaggle (Olist, 9 CSV) → Python (`urllib`, `pandas`) → SQLite: RAW → STAGING → CORE → витрина `dm_v05_basket` → CSV → Yandex DataLens.

## Технологический стек
Python 3.13.7, pandas 3.0.6, SQLite 3.50.4, Google Colab / Jupyter, Yandex DataLens.

## Схема данных
Слои: `raw_*` (9 таблиц) → `stg_*` (типизация, очистка) → `core_order`, `core_item`, `dim_state` → `dm_v05_basket` (VIEW).
<!-- вставьте скриншот или ER-диаграмму: img/er.png -->

## SQL витрины
```sql
CREATE VIEW dm_v05_basket AS
SELECT
  order_id,
  purchase_month                  AS month,
  customer_state                  AS region,
  items_cnt,
  CASE
    WHEN items_cnt >= 3 THEN '3+ товара'
    WHEN items_cnt = 2  THEN '2 товара'
    WHEN items_cnt = 1  THEN '1 товар'
    ELSE '0'
  END                             AS basket_size,
  sellers_cnt,
  CASE WHEN sellers_cnt > 1 THEN 1 ELSE 0 END AS multi_seller,
  ROUND(goods_value, 2)           AS goods_value,
  ROUND(freight_value, 2)         AS freight_value,
  ROUND(order_value, 2)           AS order_value
FROM core_order
WHERE order_status = 'delivered'
  AND items_cnt > 0
  AND purchase_month BETWEEN '2017-01-01' AND '2018-08-01'
```

## Контрольные значения
| Вопрос | Ответ |
|---|---|
| Доля заказов с 2+ товарами, % | 10.0 |
| Средний чек заказов «3+ товара», BRL | 370.96 |

## Дашборд DataLens
Ссылка: https://datalens.ru/embeds/dash#dl_embed_token=eyJhbGciOiJQUzI1NiIsInR5cCI6IkpXVCIsImtpZCI6Imt4NTh2dmx1aTh0bTMifQ.eyJlbWJlZElkIjoieGFpbDg4ZHI5YXJjZyIsInNoYXJpbmdJZCI6Iml2MzZ0dHpidGc3NjEiLCJkbEVtYmVkU2VydmljZSI6IllDX0RBVEFMRU5TX0VNQkVERElOR19TRVJWSUNFX01BUksiLCJpYXQiOjE3OTQ1OTQ2MTIsImV4cCI6MTc5NDY4MTAxMiwicGFyYW1zIjp7fX0.rlAOHt6pQpY1DSbRO-xvJor7M23qickA9MHy8kV1muEjTUWSlHs-3Q3jD98U7JUWAkB9UV5xT7-GSGci3rZZk_RTkDqW4kkqWLIWchMUKnc4gKhrG5zrq_jewuYVi9roFab2QlGo2SuzViKwWMLjodvihXv4K9AdxZmqdT1IVsKl2LEX6_Z5aZmxep2ODhLVe68kKuUeGYHDkV_fIQL9Hur7hIz_WDN1_ggGjBvZSIVfuB3BHIUVgtyJQdo6G6-2tE-Hl4_xxEcGmdtTqrtRakusYiIHDUH2A10p3m6Z89Ayu__05e4iZNsS1v8-69njCL7iLtYGmqz42Y8yj-7h-g

| № | Тип | Название |
|---|---|---|
| 1 | Индикатор | Товаров в заказе |
| 2 | Столбчатая диаграмма | Средний чек по размеру корзины |
| 3 | Круговая диаграмма | Структура заказов по размеру корзины |
| 4 | Линейная диаграмма | Товаров в заказе по месяцам |
| 5 | Комбинированная диаграмма | Заказы и доля доставки |

![Дашборд](img/dashboard.PNG)

## Выводы и бизнес-рекомендации
1. **Корзина Olist — одиночная.** 90% заказов содержат 1 товар, доля заказов с 2+ товарами — 10.0%. Средний размер корзины стабилен: 1.11–1.22 товара на заказ за 2017–2018 гг. Cross-sell на маркетплейсе почти не развит.

2. **Размер корзины напрямую влияет на чек.** Средний чек заказов «3+ товара» составляет 370.96 BRL — это в 2.4 раза выше среднего чека одиночных заказов (150 BRL). Наращивание корзины — самый прямой рычаг роста выручки.

3. **Доставка «съедает» большую часть одиночного заказа.** В заказах с 1 товаром доля доставки в стоимости ниже (14%), чем в заказах 3+ товара (19%). 

**Рекомендация:** запустить программу cross-sell — «бесплатная доставка при заказе от 2 товаров» или «-10% на второй товар». При текущей доле мультитоварных заказов 10% даже рост до 15–20% даёт +5–10% GMV без привлечения новых клиентов.
