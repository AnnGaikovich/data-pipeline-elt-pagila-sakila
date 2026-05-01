# Pagila & Sakila Data Pipeline

## Project Overview

This project implements a complete data pipeline from two demo PostgreSQL databases (Pagila and Sakila) to Snowflake, using modern data stack tools:

- **Apache Airflow** – orchestration of data replication and transformation tasks
- **Airbyte** – EL (Extract & Load) replication from PostgreSQL to Snowflake
- **dbt** – Transformations (T) inside Snowflake, building staging, intermediate, mart, and analytics layers
- **Snowflake** – cloud data warehouse as the central target

All components are containerised with Docker Compose, making local development and testing seamless.

## Objectives

- Automate the setup of Pagila and Sakila databases with Airflow DAGs.
- Configure Airbyte to replicate all tables from both databases into Snowflake, using separate schemas (`RAW_PAGILA`, `RAW_SAKILA`).
- Implement a dedicated development role (`DEV_ROLE`) in Snowflake and enforce its usage in Airflow (no admin rights for pipelines).
- Build a layered dbt project with:
  - **Staging** – clean, rename, type‑cast raw data (separate models for Pagila and Sakila)
  - **Intermediate** – business logic, joins, calculations (e.g., `int_rental_facts`, `int_customer_enriched`)
  - **Marts** – dimensional models (`dim_film`, `dim_actor`, `dim_customer`, `dim_date`) and fact tables (`fact_rental`, `fact_revenue`)
  - **Analytics** – recreate the original 7 SQL queries as dbt models
- Configure data freshness checks and sources in dbt.
- Follow Git best practices with feature branches, pull requests, and code reviews.

## Tech Stack

| Component | Technology |
|-----------|------------|
| Source databases | PostgreSQL 15 (Pagila, Sakila) |
| Orchestration | Apache Airflow 3.2.1 (CeleryExecutor) |
| EL tool | Airbyte 0.44.0 |
| Transformation | dbt-snowflake 1.11.x |
| Data warehouse | Snowflake |
| Containerisation | Docker, Docker Compose |
| Version control | Git, GitHub |

## Repository Structure
.
├── dags/ # Airflow DAGs
│ ├── check_databases.py # Test connections to Pagila/Sakila
│ └── airbyte_sync.py # Trigger Airbyte sync via API
├── logs/ # Airflow logs (gitignored)
├── plugins/ # Airflow plugins (empty)
├── data/ # Static data (if any)
├── pagila_analytics/ # dbt project
│ ├── models/
│ │ ├── staging/
│ │ │ ├── pagila/ # Staging models for Pagila
│ │ │ └── sakila/ # Staging models for Sakila
│ │ ├── intermediate/ # Business logic models
│ │ ├── marts/ # Dimensional and fact tables
│ │ └── analytics/ # Final analytical models (7 queries)
│ ├── sources.yml # Source definitions with freshness checks
│ ├── dbt_project.yml # dbt configuration
│ └── profiles.yml (gitignored – contains Snowflake credentials)
├── docker-compose.yml # Main orchestration file (Airflow, Postgres bases)
├── .env # Environment variables (ignored)
├── .gitignore
└── README.md

## Prerequisites

- Docker Desktop (with WSL2 on Windows)
- Python 3.9+ (for dbt and local testing)
- Git
- Snowflake account (free trial is sufficient)

## Setup Instructions

### 1. Clone the repository

```bash
git clone https://github.com/your-username/data-pipeline-elt-pagila-sakila.git
cd data-pipeline-elt-pagila-sakila
2. Configure environment
Create a .env file (or use the provided example) with the following variables:

text
AIRFLOW_IMAGE_NAME=apache/airflow:3.2.1
AIRFLOW_UID=50000
_FERNET_KEY=your_fernet_key
_AIRFLOW_WWW_USER_USERNAME=airflow
_AIRFLOW_WWW_USER_PASSWORD=airflow
3. Start the whole stack
bash
docker-compose up -d
This will start:

Airflow (webserver, scheduler, worker, etc.)

PostgreSQL databases for Pagila (port 5433) and Sakila (port 5434)

(Airbyte is run separately – see step 5)

Wait for all containers to be healthy.

4. Airflow connections
Access Airflow UI at http://localhost:8080 (login: airflow/airflow).
Create the following connections:

pagila_conn (Postgres): Host=pagila, Port=5432, Database=pagila, User=postgres, Password=postgres

sakila_conn (Postgres): Host=sakila, Port=5432, Database=sakila, User=postgres, Password=postgres

airbyte_api (HTTP): Host=http://host.docker.internal:8000

5. Run Airbyte
Airbyte is not part of the main docker-compose.yml to avoid conflicts. Start it separately:

bash
git clone --branch v0.44.0 https://github.com/airbytehq/airbyte.git
cd airbyte
docker-compose up -d
Access Airbyte UI at http://localhost:8001 (login: airbyte/password).
Configure:

Source Pagila: Postgres, host=host.docker.internal, port=5433, database=pagila

Source Sakila: similarly with port=5434

Destination Snowflake: create two destinations – one with schema=RAW_PAGILA, another with schema=RAW_SAKILA

Connections: create one connection per source/destination pair, selecting only tables (exclude views like rental_by_category, actor_info, etc.)

After creation, copy the connectionId from the URL and update dags/airbyte_sync.py.

6. dbt setup
Install dbt and initialise the project:

bash
pip install dbt-snowflake
cd pagila_analytics
dbt debug   # verify connection
dbt run     # build all models
Your profiles.yml (located in ~/.dbt/) should point to Snowflake using a dedicated development role:

yaml
pagila_analytics:
  target: dev
  outputs:
    dev:
      type: snowflake
      account: <your_account_identifier>
      user: <your_username>
      password: <your_password>
      role: DEV_ROLE
      warehouse: COMPUTE_WH
      database: PAGILA_ANALYTICS
      schema: RAW_PAGILA
      threads: 1
Important: The profiles.yml file is not committed to the repository (see .gitignore). Each team member manages their own credentials.

7. Snowflake role configuration
Instead of using ACCOUNTADMIN for Airflow/dbt, a dedicated DEV_ROLE was created with minimal privileges:

sql
CREATE ROLE DEV_ROLE;
GRANT USAGE ON DATABASE PAGILA_ANALYTICS TO ROLE DEV_ROLE;
GRANT USAGE ON ALL SCHEMAS IN DATABASE PAGILA_ANALYTICS TO ROLE DEV_ROLE;
GRANT CREATE TABLE, CREATE VIEW ON SCHEMA PAGILA_ANALYTICS.RAW_PAGILA TO ROLE DEV_ROLE;
-- similar grants for RAW_SAKILA, staging, intermediate, etc.
GRANT ALL ON WAREHOUSE COMPUTE_WH TO ROLE DEV_ROLE;
The Airflow Snowflake connection uses DEV_ROLE (not admin). This follows the principle of least privilege.

8. Running the pipeline
Test database connections – trigger DAG check_pagila_and_sakila.

Replicate data – trigger DAG airbyte_sync_pagila_sakila. It will call Airbyte API and start the sync jobs.

Transform data – after replication, run dbt run from the pagila_analytics directory, or schedule a DAG that executes dbt run via BashOperator.
All analytical models will be built in Snowflake schemas (staging_pagila, staging_sakila, intermediate, marts, analytics).

Key dbt Models
Staging (views)
stg_pagila_actor, stg_pagila_film, ... (Pagila)

stg_sakila_actor, stg_sakila_film, ... (Sakila)

Intermediate (tables)
int_film_actor_bridge – links films with actors

int_rental_facts – calculates rental hours and revenue per rental

int_customer_enriched – customer with address, city, country

Marts (tables)
dim_film – film dimension including category name

dim_actor – actor dimension

dim_customer – customer dimension with location

dim_date – date dimension (1990‑2030)

fact_rental – rental transactions fact

fact_revenue – revenue fact (payments)

Analytics (tables) – original 7 queries
film_category_distribution

top_rented_actors

highest_revenue_category

films_not_in_inventory

top_children_actors

customer_distribution_by_city

category_rental_hours_analysis

Freshness Tests
Defined in models/staging/sources.yml. For each source table, freshness is checked every 24 hours (warning after 24h, error after 48h).

Git Workflow
master – protected branch, only via PR

development – integration branch

feature/* – feature branches (e.g., feature/airflow-dags, feature/airbyte-setup, feature/dbt-setup)

Each pull request requires a reviewer (aleksandr-semenov-git)

Future Improvements
Add incremental loading in Airbyte (currently full refresh)

Schedule dbt runs via Airflow DAG

Add dbt documentation and testing

Integrate with a BI tool (e.g., Looker, Power BI)

Implement more sophisticated error handling and alerting

Troubleshooting
Airbyte cannot connect to Pagila – ensure the databases are in the same Docker network or use host.docker.internal.

dbt model fails with ambiguous column – add explicit table aliases.

stg_pagila_payment missing last_update – the payment table does not have that column; remove it from the staging model.

Permission errors in Snowflake – verify that DEV_ROLE has the necessary grants.

