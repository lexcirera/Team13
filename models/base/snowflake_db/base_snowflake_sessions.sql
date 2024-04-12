SELECT _FIVETRAN_ID,
        OS,
        SESSION_AT AS SESSION_TS,
        CAST(CLIENT_ID AS STRING) AS CLIENT_ID,
        IP,
        SESSION_ID,
        _FIVETRAN_DELETED,
        _FIVETRAN_SYNCED AS _FIVETRAN_SYNCED_TS,
FROM {{source('snowflake','sessions')}}