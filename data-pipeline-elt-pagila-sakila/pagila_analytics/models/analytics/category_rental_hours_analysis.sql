with rental_hours as (
    select
        c.category_name,
        datediff('hour', r.rental_date, r.return_date) as rental_hours,
        ci.city
    from {{ source('pagila', 'rental') }} r
    join {{ source('pagila', 'inventory') }} i on r.inventory_id = i.inventory_id
    join {{ source('pagila', 'film') }} f on i.film_id = f.film_id
    join {{ source('pagila', 'film_category') }} fc on f.film_id = fc.film_id
    join {{ ref('stg_pagila_category') }} c on fc.category_id = c.category_id
    join {{ source('pagila', 'customer') }} cu on r.customer_id = cu.customer_id
    join {{ source('pagila', 'address') }} a on cu.address_id = a.address_id
    join {{ ref('stg_pagila_city') }} ci on a.city_id = ci.city_id
    where r.return_date is not null
)
select
    city,
    category_name,
    sum(rental_hours) as total_rental_hours
from rental_hours
where city ilike 'a%' or city like '%-%'
group by city, category_name
qualify rank() over (partition by city order by total_rental_hours desc) = 1
order by city