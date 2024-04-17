select
    joins.employee_id,
    joins.hire_date,
    joins.name,
    joins.city,
    joins.address,
    joins.title,
    joins.annual_salary,
    quits.quit_date
from {{ ref("base_google_drive_hr_joins") }} as joins
left join
    {{ ref("base_google_drive_hr_quits") }} as quits
    on joins.employee_id = quits.employee_id
