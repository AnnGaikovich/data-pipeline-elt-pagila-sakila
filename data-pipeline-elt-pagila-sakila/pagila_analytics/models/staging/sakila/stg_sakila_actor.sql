with source as (
    select * from {{ source('sakila', 'actor') }}
)
select
    actor_id,
    first_name,
    last_name,
    last_update
from source