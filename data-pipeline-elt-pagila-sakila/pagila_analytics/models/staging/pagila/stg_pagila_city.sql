with source as (
    select * from {{ source('pagila', 'city') }}
)
select
    city_id,
    city,
    country_id,
    last_update as updated_at
from source