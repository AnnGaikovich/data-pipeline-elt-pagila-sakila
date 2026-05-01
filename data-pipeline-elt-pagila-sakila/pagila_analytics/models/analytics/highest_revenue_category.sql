with revenue_by_category as (
    select
        c.category_name,
        sum(p.amount) as total_revenue
    from {{ source('pagila', 'payment') }} p
    join {{ source('pagila', 'rental') }} r on p.rental_id = r.rental_id
    join {{ source('pagila', 'inventory') }} i on r.inventory_id = i.inventory_id
    join {{ source('pagila', 'film') }} f on i.film_id = f.film_id
    join {{ source('pagila', 'film_category') }} fc on f.film_id = fc.film_id
    join {{ ref('stg_pagila_category') }} c on fc.category_id = c.category_id
    group by c.category_name
)
select category_name, total_revenue
from revenue_by_category
order by total_revenue desc
limit 1