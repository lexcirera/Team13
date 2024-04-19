with daily_emp_cost as (
    Select
    ie.hire_date,
    ie.quit_date,
    sum(round(ie.annual_salary/365,2)) as daily_salary,
    from {{ ref("int_employee") }} as ie
    group by 1,2
),
daily_salary_cost AS (
    SELECT 
        date_series.date AS date,
        COALESCE(SUM(daily_salary), 0) AS daily_salary_cost
    FROM (
        SELECT hire_date AS date FROM daily_emp_cost
        UNION
        SELECT quit_date FROM daily_emp_cost WHERE quit_date IS NOT NULL
    ) AS date_series
    LEFT JOIN daily_emp_cost ON date_series.date BETWEEN hire_date AND COALESCE(quit_date, CURRENT_DATE)
    GROUP BY date_series.date
),

daily_order_val as (
    select
    Date(io.order_date) as Date,
    round(sum(io.order_value),2) as daily_order_revenue,
    from {{ ref("int_order") }} as io
    group by 1
),

daily_order_cost as (
    select
    Date(io.order_date) as Date,
    round(sum(io.tax_rate*io.order_value),2) as daily_taxes_cost,
    round(sum(io.shipping_cost),2) as daily_shipping_cost,
    from {{ ref("int_order") }} as io
    group by 1
),

daily_refunds_cost as (
    select
    DATE(io.return_date) as refunded_date,
    round(sum(io.order_value),2) as daily_refunded_cost,
    from {{ ref("int_order") }} as io
    where io.return_date IS NOT NULL AND io.is_refunded = TRUE
    group by 1
),

daily_expenses_cost as (
    select
    gde.date as date,
    round(sum(gde.expense_amount),2) as expenses_cost
    from {{ ref("base_google_drive_expenses") }} as gde
    group by 1 
)

Select
    dsc.date,
    dov.daily_order_revenue as orders_revenue,
    doc.daily_taxes_cost as taxes_cost,
    doc.daily_shipping_cost as shipping_cost,
    
    CASE 
        WHEN drc.daily_refunded_cost IS NOT NULL THEN drc.daily_refunded_cost
        ELSE 0
        END AS refund_cost,
    -- bc some days wze don't make refunds so refund cost will be 0$

    dsc.daily_salary_cost as salaries_cost,
    dc.expenses_cost as expenses_cost,
    round(orders_revenue - taxes_cost - shipping_cost - refund_cost - salaries_cost - expenses_cost,2) as profit

from daily_salary_cost as dsc
left join daily_order_val as dov 
on dsc.date = dov.date
left join daily_order_cost as doc 
on dsc.date = doc.date
left join daily_refunds_cost as drc 
on dsc.date = drc.refunded_date
left join daily_expenses_cost as dc
on dsc.date = dc.date 
order by 1 ASC
