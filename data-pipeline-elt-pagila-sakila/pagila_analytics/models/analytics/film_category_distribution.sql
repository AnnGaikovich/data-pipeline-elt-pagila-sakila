select
    c.category_name,
    count(f.film_id) as film_count
from {{ ref('dim_film') }} f
join {{ source('pagila', 'film_category') }} fc on f.film_id = fc.film_id
join {{ ref('stg_pagila_category') }} c on fc.category_id = c.category_id
group by c.category_name
order by film_count desc