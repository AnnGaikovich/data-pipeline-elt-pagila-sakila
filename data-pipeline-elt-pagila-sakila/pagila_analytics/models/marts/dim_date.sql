{{
    config(
        materialized='table'
    )
}}

with dates as (
    select
        date_day as date_key,
        year(date_day) as year,
        month(date_day) as month,
        monthname(date_day) as month_name,
        day(date_day) as day,
        quarter(date_day) as quarter,
        week(date_day) as week
    from (
        select dateadd(day, row_number() over (order by null)-1, '1990-01-01') as date_day
        from table(generator(rowcount => 20000))
    ) d
    where date_day <= '2030-12-31'
)
select
    date_key,
    year,
    month,
    month_name,
    day,
    quarter,
    week
from dates