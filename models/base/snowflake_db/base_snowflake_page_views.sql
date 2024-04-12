SELECT _FIVETRAN_ID,
        VIEW_AT AS VIEW_TS,
        SESSION_ID,
        PAGE_NAME,
        _FIVETRAN_DELETED,
        _FIVETRAN_SYNCED AS _FIVETRAN_SYNCED_TS,
FROM {{source('snowflake','page_views')}}