from datetime import datetime, timedelta
from airflow import DAG
from airflow.operators.python import PythonOperator
from airflow.models import Variable
import requests
import time
import logging

# All settings via Airflow Variables
AIRBYTE_API_URL = Variable.get("airbyte_api_url", default_var="http://host.docker.internal:8000/api/v1")
AIRBYTE_USER = Variable.get("airbyte_user", default_var="airbyte")
AIRBYTE_PASSWORD = Variable.get("airbyte_password", default_var="password")

# Mandatory variables — no default_var to fail DAG loading if not set
CONNECTION_ID_PAGILA = Variable.get("airbyte_connection_id_pagila")
CONNECTION_ID_SAKILA = Variable.get("airbyte_connection_id_sakila")


def trigger_airbyte_sync(connection_id, wait_for_completion=True, poll_interval=10, timeout=600):
    """
    Triggers an Airbyte sync and optionally waits for its completion.
    Returns the final status.
    """
    url_sync = f"{AIRBYTE_API_URL}/connections/sync"
    payload = {"connectionId": connection_id}

    try:
        # Step 1: trigger sync
        logging.info(f"Starting sync for connection {connection_id}")
        response = requests.post(url_sync, json=payload, auth=(AIRBYTE_USER, AIRBYTE_PASSWORD), timeout=30)
        response.raise_for_status()
        job_data = response.json()

        # Different Airbyte versions may use different field names
        job_id = job_data.get("job", {}).get("id") or job_data.get("jobId")
        if not job_id:
            raise ValueError(f"Job ID not found in response: {job_data}")

        logging.info(f"Sync triggered, job_id={job_id}")

        if not wait_for_completion:
            return {"status": "started", "job_id": job_id}

        # Step 2: poll job status until completion or timeout
        url_job = f"{AIRBYTE_API_URL}/jobs/get"
        start = time.time()
        while time.time() - start < timeout:
            status_resp = requests.post(url_job, json={"id": job_id}, auth=(AIRBYTE_USER, AIRBYTE_PASSWORD), timeout=10)
            status_resp.raise_for_status()
            status = status_resp.json().get("job", {}).get("status")

            if status == "succeeded":
                logging.info(f"Job {job_id} completed successfully")
                return {"status": "succeeded", "job_id": job_id}
            elif status in ["failed", "cancelled", "error"]:
                error_msg = f"Job {job_id} finished with error: {status}"
                logging.error(error_msg)
                raise Exception(error_msg)
            else:
                logging.info(f"Job {job_id} is in state {status}, waiting {poll_interval} sec...")
                time.sleep(poll_interval)

        raise TimeoutError(f"Job {job_id} did not finish within {timeout} seconds")

    except requests.exceptions.RequestException as e:
        logging.error(f"Airbyte API call error: {e}")
        raise
    except Exception as e:
        logging.error(f"Critical sync error: {e}")
        raise


def sync_pagila():
    trigger_airbyte_sync(CONNECTION_ID_PAGILA, wait_for_completion=True)


def sync_sakila():
    trigger_airbyte_sync(CONNECTION_ID_SAKILA, wait_for_completion=True)


default_args = {
    'owner': 'anna',
    'depends_on_past': False,
    'start_date': datetime(2025, 5, 1),
    'retries': 2,
    'retry_delay': timedelta(minutes=1),
    'retry_exponential_backoff': True,
}

with DAG(
        'airbyte_sync_pagila_sakila',
        default_args=default_args,
        description='Launch Airbyte replication from Pagila and Sakila to Snowflake',
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