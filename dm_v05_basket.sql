DROP VIEW IF EXISTS dm_v05_basket;
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
  AND purchase_month BETWEEN '2017-01-01' AND '2018-08-01';
