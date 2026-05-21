with source as (
    select * from {{ source('pagila', 'actor') }}
)
select
    actor_id,
    first_name,
    last_name,
    last_update as updated_at
from source