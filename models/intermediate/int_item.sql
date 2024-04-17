select
    items.item_name,
    sum(items.add_to_cart_quantity) as total_add_cart,
    sum(items.remove_from_cart_quantity) as total_remove_cart,
    total_add_cart - total_remove_cart as net_sells,
    array_agg(distinct(items.price_per_unit)) as item_prices,
    round(sum((items.add_to_cart_quantity-items.remove_from_cart_quantity)*items.price_per_unit)/net_sells,2) as average_selling_price,
    round(sum((items.add_to_cart_quantity-items.remove_from_cart_quantity)*items.price_per_unit),2) as total_item_revenue,
from {{ ref("base_snowflake_items_views") }} as items
group by 1