with source as (
    select * from {{ source('pagila', 'film') }}
)
select
    film_id,
    title,
    description,
    release_year,
    language_id,
    rental_duration,
    rental_rate,
    length,
    replacement_cost,
    rating,
    last_update as updated_at,
    special_features
from source