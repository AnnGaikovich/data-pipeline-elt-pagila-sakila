with rental_hours as (
    select
        df.category_name,
        fr.rental_hours,
        dc.city
    from {{ ref('fact_rental') }} fr
    join {{ ref('dim_film') }} df on fr.film_id = df.film_id
    join {{ ref('dim_customer') }} dc on fr.customer_id = dc.customer_id
    where fr.rental_hours is not null
)
select
    city,
    category_name,
    sum(rental_hours) as total_rental_hours
from rental_hours
where city ilike 'a%' or city like '%-%'
group by city, category_name
qualify rank() over (partition by city order by total_rental_hours desc) = 1
order by city