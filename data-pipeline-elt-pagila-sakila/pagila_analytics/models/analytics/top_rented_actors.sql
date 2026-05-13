with actor_rentals as (
    select
        fab.actor_id,
        count(fr.rental_id) as rental_count
    from {{ ref('fact_rental') }} fr
    join {{ ref('int_film_actor_bridge') }} fab on fr.film_id = fab.film_id
    group by fab.actor_id
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