with source as (
    select * from {{ source('sakila', 'film_actor') }}
)
select
    actor_id,
    film_id,
    last_update as updated_at
from source