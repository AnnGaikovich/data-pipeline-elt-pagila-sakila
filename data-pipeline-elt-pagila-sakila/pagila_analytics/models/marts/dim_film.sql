with film as (
    select * from {{ ref('stg_pagila_film') }}
),
film_category as (
    select * from {{ source('pagila', 'film_category') }}
),
category as (
    select * from {{ ref('stg_pagila_category') }}
)
select
    f.film_id,
    f.title,
    f.description,
    f.release_year,
    f.language_id,
    f.rental_duration,
    f.rental_rate,
    f.length,
    f.replacement_cost,
    f.rating,
    c.category_name
from film f
left join film_category fc on f.film_id = fc.film_id
left join category c on fc.category_id = c.category_id