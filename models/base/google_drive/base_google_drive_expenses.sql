SELECT _FILE,
       _LINE,
       _MODIFIED AS _MODIFIED_TS,
       _FIVETRAN_SYNCED AS _FIVETRAN_SYNCED_TS,
       DATE,
       EXPENSE_TYPE,
       CAST(REPLACE(EXPENSE_AMOUNT,'$','')AS FLOAT) AS EXPENSE_AMOUNT  
FROM {{source("google_drive", "expenses")}}