from datetime import datetime
from airflow import DAG
from airflow.providers.common.sql.operators.sql import SQLExecuteQueryOperator

default_args = {
    'owner': 'anna',
    'depends_on_past': False,
    'start_date': datetime(2025, 5, 1),
    'retries': 1,
}

with DAG(
    'check_pagila_and_sakila',
    default_args=default_args,
    description='Проверка доступности баз Pagila и Sakila',
    schedule=None,   # только ручной запуск (было schedule_interval=None)
    catchup=False,
    tags=['pagila', 'sakila', 'test'],
) as dag:

    check_pagila = SQLExecuteQueryOperator(
        task_id='check_pagila',
        conn_id='pagila_conn',          # обрати внимание: параметр называется conn_id, а не postgres_conn_id
        sql='SELECT 1;'
    )

    check_sakila = SQLExecuteQueryOperator(
        task_id='check_sakila',
        conn_id='sakila_conn',
        sql='SELECT 1;'
    )

    check_pagila >> check_sakila