# Pagila & Sakila Data Pipeline

## Project Overview
This project automates the ingestion and transformation of data from two demo databases (Pagila and Sakila) into Snowflake using a modern Data Stack:

- **Apache Airflow** – workflow orchestration
- **Airbyte** – data replication (EL) from PostgreSQL to Snowflake
- **dbt (dbt-snowflake)** – data transformation (T) inside Snowflake
- **Snowflake** – cloud data warehouse target

## Objectives
- Automate loading of all Pagila and Sakila tables into Snowflake (separate schemas)
- Configure Airflow to use a **development role** (no admin privileges)
- Build a layered dbt project: staging → intermediate → marts → analytics
- Recreate the 7 analytical queries from the initial SQL task as dbt models

## Tech Stack
- **PostgreSQL** – source databases (Pagila, Sakila)
- **Snowflake** – destination warehouse
- **Airbyte** – EL replication (Postgres → Snowflake)
- **Apache Airflow** – orchestration (DAGs to trigger replication and dbt runs)
- **dbt** – transformations, testing, documentation