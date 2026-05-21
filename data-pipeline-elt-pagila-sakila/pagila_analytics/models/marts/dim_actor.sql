select
    actor_id,
    first_name,
    last_name
from {{ ref('stg_pagila_actor') }}