with film_actor as (
    select
        film_id,
        actor_id
    from {{ ref('stg_pagila_film_actor') }}   -- если у вас есть stg_pagila_film_actor
)
select
    film_id,
    actor_id,
    concat('FILM_ACTOR_', film_id, '_', actor_id) as bridge_id
from film_actor