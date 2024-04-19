Select 
    so.order_id,
    min(so.order_ts) as order_date,
    min(so.session_id) as session_id,

    min(ss.client_id) as client_id,
    min(so.client_name) as client_name,
    min(so.phone) as phone,
    min(so.state) as state,
    min(so.shipping_address) as shipping_address,

    min(so.payment_method) as payment_method,
    min(so.payment_info) as payment_info,
    round(sum(siv.price_per_unit*(siv.add_to_cart_quantity - siv.remove_from_cart_quantity)),2) as order_value,
    min(so.tax_rate) as tax_rate,
    --min(so.tax_rate*order_value) as tax_value,
    min(so.shipping_cost) as shipping_cost,

    CASE 
        WHEN min(gdr.order_id) IS NOT NULL THEN TRUE 
        ELSE FALSE
        END AS is_returned,
    
    CASE 
        WHEN min(gdr.order_id) IS NOT NULL THEN min(gdr.RETURN_DATE) 
        ELSE NULL
        END AS return_date,

    CASE 
        WHEN min(gdr.order_id) IS NOT NULL THEN max(gdr.IS_REFUNDED) 
        ELSE NULL
        END AS is_refunded,
    

from {{ ref("base_snowflake_orders") }} as so
left join {{ ref("base_snowflake_sessions") }} as ss
on so.session_id = ss.session_id
left join {{ ref("base_snowflake_items_views") }} as siv
on ss.session_id = siv.session_id
left join  {{ ref("base_google_drive_returns") }} as gdr
on so.order_id = gdr.order_id

where siv.add_to_cart_quantity > siv.remove_from_cart_quantity

group by so.order_id
order by 2 ASC

