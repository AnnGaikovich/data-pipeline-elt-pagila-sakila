from datetime import datetime
from airflow import DAG
from airflow.operators.python import PythonOperator
import requests

AIRBYTE_API_URL = "http://host.docker.internal:8000/api/v1"
CONNECTION_ID_PAGILA = Variable.get("airbyte_connection_id_pagila")
CONNECTION_ID_SAKILA = Variable.get("airbyte_connection_id_sakila")

def trigger_airbyte_sync(connection_id):
    url = f"{AIRBYTE_API_URL}/connections/sync"
    payload = {"connectionId": connection_id}

    response = requests.post(url, json=payload, auth=('airbyte', 'password'))
    response.raise_for_status()
    return response.json()

def sync_pagila():
    trigger_airbyte_sync(CONNECTION_ID_PAGILA)

def sync_sakila():
    trigger_airbyte_sync(CONNECTION_ID_SAKILA)

default_args = {
    'owner': 'anna',
    'depends_on_past': False,
    'start_date': datetime(2025, 5, 1),
    'retries': 1,
}

with DAG(
    'airbyte_sync_pagila_sakila',
    default_args=default_args,
    description='Запуск репликации Airbyte из Pagila и Sakila в Snowflake',
    schedule='@daily',
    catchup=False,
    tags=['airbyte', 'pagila', 'sakila', 'snowflake'],
) as dag:

    sync_pagila_task = PythonOperator(
        task_id='sync_pagila',
        python_callable=sync_pagila,
    )

    sync_sakila_task = PythonOperator(
        task_id='sync_sakila',
        python_callable=sync_sakila,
    )

    sync_pagila_task >> sync_sakila_task