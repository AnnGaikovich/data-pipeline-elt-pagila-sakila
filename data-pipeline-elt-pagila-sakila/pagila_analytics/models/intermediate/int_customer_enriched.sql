with customer as (
    select
        customer_id,
        first_name,
        last_name,
        email,
        address_id
    from {{ ref('stg_pagila_customer') }}
),
address as (
    select
        address_id,
        address,
        city_id
    from {{ ref('stg_pagila_address') }}
),
city as (
    select
        city_id,
        city,
        country_id
    from {{ ref('stg_pagila_city') }}
),
country as (
    select
        country_id,
        country
    from {{ source('pagila', 'country') }}
)
select
    c.customer_id,
    c.first_name,
    c.last_name,
    c.email,
    a.address,
    ci.city,
    co.country
from customer c
left join address a on c.address_id = a.address_id
left join city ci on a.city_id = ci.city_id
left join country co on ci.country_id = co.country_id