select
    city,
    sum(is_active) as active_customers,
    sum(1 - is_active) as inactive_customers
from {{ ref('dim_customer') }}
group by city
order by inactive_customers desc