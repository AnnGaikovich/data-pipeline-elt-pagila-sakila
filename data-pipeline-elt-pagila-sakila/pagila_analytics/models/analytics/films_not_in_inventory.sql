select
    df.film_id,
    df.title
from {{ ref('dim_film') }} df
left join {{ ref('stg_pagila_inventory') }} i on df.film_id = i.film_id
where i.inventory_id is null