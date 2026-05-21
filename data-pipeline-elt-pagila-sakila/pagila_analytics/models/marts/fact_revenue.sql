with payment as (
    select
        payment_id,
        customer_id,
        staff_id,
        rental_id,
        amount,
        payment_date
    from {{ ref('stg_pagila_payment') }}
)
select
    payment_id,
    customer_id,
    staff_id,
    rental_id,
    amount,
    payment_date,
    date(payment_date) as payment_date_key
from payment