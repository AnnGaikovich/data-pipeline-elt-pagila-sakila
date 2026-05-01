with child_films as (
    select
        fa.actor_id,
        count(distinct fa.film_id) as film_count
    from {{ source('pagila', 'film_actor') }} fa
    join {{ source('pagila', 'film_category') }} fc on fa.film_id = fc.film_id
    join {{ ref('stg_pagila_category') }} c on fc.category_id = c.category_id
    where c.category_name = 'Children'
    group by fa.actor_id
),
ranked as (
    select
        actor_id,
        film_count,
        rank() over (order by film_count desc) as rank
    from child_films
)
select
    a.actor_id,
    a.first_name,
    a.last_name,
    r.film_count
from ranked r
join {{ ref('dim_actor') }} a on r.actor_id = a.actor_id
where r.rank <= 3
order by r.film_count desc, a.last_name, a.first_name