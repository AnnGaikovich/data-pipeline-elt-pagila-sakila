with source as (
    select * from {{ source('sakila', 'country') }}
)
select
    country_id,
    country,
    last_update as updated_at
from source