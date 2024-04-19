with
    item_view_metrics as (
        select item_views.session_id as session_id, count(*) as number_items_viewed

        from {{ ref("base_snowflake_items_views") }} as item_views
        group by item_views.session_id
    ),

    page_view_metrics as (
        select page_views.session_id as session_id, count(*) as number_pages_viewed

        from {{ ref("base_snowflake_page_views") }} as page_views
        group by page_views.session_id
    ),

    order_metrics as (
        select orders.session_id as session_id, count(*) as number_orders
        from {{ ref("base_snowflake_orders") }} as orders
        group by orders.session_id

    )

select
    sessions.session_id,
    sessions.session_ts,
    sessions.os,
    sessions.client_id,
    sessions.ip,
    coalesce(page_views.number_pages_viewed, 0) as number_pages_viewed,
    coalesce(item_views.number_items_viewed, 0) as number_items_viewed,
    coalesce(order_metrics.number_orders, 0) as number_orders
from {{ ref("base_snowflake_sessions") }} as sessions
left join item_view_metrics as item_views on item_views.session_id = sessions.session_id
left join page_view_metrics as page_views on page_views.session_id = sessions.session_id
left join order_metrics on order_metrics.session_id = sessions.session_id
group by 1