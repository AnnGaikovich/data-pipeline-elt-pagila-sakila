with rental_data as (
    select
        r.rental_id,
        r.rental_date,
        r.inventory_id,
        r.customer_id,
        r.return_date,
        p.amount as revenue
    from {{ ref('stg_pagila_rental') }} r
    left join {{ ref('stg_pagila_payment') }} p on r.rental_id = p.rental_id
)
select
    rental_id,
    rental_date,
    return_date,
    datediff('hour', rental_date, return_date) as rental_hours,
    revenue,
    inventory_id,
    customer_id
from rental_data
where return_date is not null