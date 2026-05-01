select
    city,
    count(case when is_active = 1 then 1 end) as active_customers,
    count(case when is_active = 0 then 1 end) as inactive_customers
from {{ ref('dim_customer') }} dc
join {{ ref('stg_pagila_customer') }} c on dc.customer_id = c.customer_id
group by city
order by inactive_customers desc