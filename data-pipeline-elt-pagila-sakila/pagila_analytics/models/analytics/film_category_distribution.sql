select
    category_name,
    count(film_id) as film_count
from {{ ref('dim_film') }}
where category_name is not null   -- films without category not included
group by category_name
order by film_count desc