with source as (
    select * from {{ source('sakila', 'category') }}
)
select
    category_id,
    name as category_name,
    last_update as updated_at
from source