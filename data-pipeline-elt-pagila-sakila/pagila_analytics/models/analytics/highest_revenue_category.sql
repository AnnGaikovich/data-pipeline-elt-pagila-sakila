with revenue_by_category as (
    select
        df.category_name,
        sum(fr.revenue) as total_revenue
    from {{ ref('fact_rental') }} fr
    join {{ ref('dim_film') }} df on fr.film_id = df.film_id
    group by df.category_name
)
select category_name, total_revenue
from revenue_by_category
order by total_revenue desc
limit 1