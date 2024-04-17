WITH temp1 as (
SELECT *, ROW_NUMBER() OVER(PARTITION BY ORDER_ID ORDER BY ORDER_TS ASC) AS row_n
FROM {{ref("base_snowflake_orders")}}
),

temp2 as (
SELECT oo.order_id,
       oo.order_ts,
       oo.payment_method,
       oo.tax_rate,
       oo.phone,
       oo.shipping_address,
       oo.payment_info,
       oo.state,
       oo.shipping_cost,
       oo.client_name,
       SUM(ii.price_per_unit * (ii.add_to_cart_quantity - ii.remove_from_cart_quantity)) AS price_of_order,
       rr.return_date,
       rr.is_refunded, 
       oo.row_n
FROM temp1 AS oo
LEFT JOIN {{ref("base_snowflake_items_views")}} AS ii
ON oo.session_id = ii.session_id 
LEFT JOIN {{ref("base_google_drive_returns")}} AS rr
ON oo.order_id = rr.order_id
WHERE ii.add_to_cart_quantity - ii.remove_from_cart_quantity > 0
GROUP BY ALL
)

SELECT *
FROM temp2
WHERE 1=1
AND row_n = 1