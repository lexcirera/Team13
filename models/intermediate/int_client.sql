WITH ranking AS (
SELECT *, ROW_NUMBER() OVER(PARTITION BY CLIENT_NAME ORDER BY ORDER_TS DESC) AS row_n
FROM {{ref("base_snowflake_orders")}}
)

SELECT CLIENT_NAME, 
       PHONE,
       SHIPPING_ADDRESS,
       PAYMENT_INFO,
       STATE
FROM ranking 
WHERE row_n = 1