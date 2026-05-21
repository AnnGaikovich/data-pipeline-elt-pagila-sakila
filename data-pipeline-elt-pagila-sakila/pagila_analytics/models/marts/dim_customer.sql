select
    c.customer_id,
    c.first_name,
    c.last_name,
    c.email,
    c.address,
    c.city,
    c.country,
    s.is_active
from {{ ref('int_customer_enriched') }} c
left join {{ ref('stg_pagila_customer') }} s on c.customer_id = s.customer_id