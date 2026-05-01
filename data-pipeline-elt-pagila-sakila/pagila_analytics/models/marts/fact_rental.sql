with rental_facts as (
    select
        rental_id,
        rental_date,
        return_date,
        rental_hours,
        revenue,
        inventory_id,
        customer_id
    from {{ ref('int_rental_facts') }}
),
inventory as (
    select inventory_id, film_id from {{ ref('stg_pagila_inventory') }}
)
select
    rf.rental_id,
    rf.rental_date,
    rf.return_date,
    rf.rental_hours,
    rf.revenue,
    i.film_id,
    rf.customer_id,
    date(rf.rental_date) as rental_date_key
from rental_facts rf
left join inventory i on rf.inventory_id = i.inventory_id