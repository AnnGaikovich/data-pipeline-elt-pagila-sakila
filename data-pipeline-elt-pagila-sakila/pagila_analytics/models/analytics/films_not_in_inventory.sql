select
    f.film_id,
    f.title
from {{ source('pagila', 'film') }} f
left join {{ source('pagila', 'inventory') }} i on f.film_id = i.film_id
where i.inventory_id is null