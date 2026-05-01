select
    customer_id,
    first_name,
    last_name,
    email,
    address,
    city,
    country
from {{ ref('int_customer_enriched') }}