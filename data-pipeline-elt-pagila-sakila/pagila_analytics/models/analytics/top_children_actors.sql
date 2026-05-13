with child_films as (
    select
        fab.actor_id,
        count(distinct fab.film_id) as film_count
    from {{ ref('int_film_actor_bridge') }} fab
    join {{ ref('dim_film') }} df on fab.film_id = df.film_id
    where df.category_name = 'Children'
    group by fab.actor_id
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