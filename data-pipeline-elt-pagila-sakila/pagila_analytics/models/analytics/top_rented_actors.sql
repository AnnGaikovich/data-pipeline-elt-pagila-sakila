with actor_rentals as (
    select
        fa.actor_id,
        count(r.rental_id) as rental_count
    from {{ source('pagila', 'film_actor') }} fa
    join {{ source('pagila', 'inventory') }} i on fa.film_id = i.film_id
    join {{ source('pagila', 'rental') }} r on i.inventory_id = r.inventory_id
    group by fa.actor_id
)
select
    a.actor_id,
    a.first_name,
    a.last_name,
    ar.rental_count
from {{ ref('dim_actor') }} a
join actor_rentals ar on a.actor_id = ar.actor_id
order by ar.rental_count desc
limit 10