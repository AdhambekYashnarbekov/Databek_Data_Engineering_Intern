from datetime import datetime, timedelta
from airflow import DAG
from airflow.providers.postgres.operators.postgres import PostgresOperator
from airflow.operators.bash import BashOperator

default_args = {
    "owner": "data-engineering",
    "depends_on_past": False,
    "email_on_failure": False,
    "retries": 1,
    "retry_delay": timedelta(minutes=5),
}

# Idempotent load: deletes target date partition before inserting
IDEMPOTENT_LOAD_SQL = """
BEGIN;

DELETE FROM staging.orders
WHERE order_date = '{{ ds }}'::DATE;

INSERT INTO staging.orders (
    order_id,
    customer_id,
    order_date,
    status,
    total_amount,
    loaded_at
)
SELECT
    order_id,
    customer_id,
    order_date,
    status,
    total_amount,
    CURRENT_TIMESTAMP
FROM raw.orders
WHERE order_date = '{{ ds }}'::DATE;

COMMIT;
"""

with DAG(
    dag_id="daily_orders_revenue_pipeline",
    default_args=default_args,
    description="Idempotently loads yesterday's orders to staging and runs dbt revenue models",
    schedule="@daily",
    start_date=datetime(2026, 1, 1),
    catchup=False,
    tags=["postgres", "dbt", "revenue"],
) as dag:

    load_yesterday_orders_to_staging = PostgresOperator(
        task_id="load_yesterday_orders_to_staging",
        postgres_conn_id="warehouse_pg",
        sql=IDEMPOTENT_LOAD_SQL,
    )

    run_dbt_models = BashOperator(
        task_id="run_dbt_models",
        bash_command="cd /opt/airflow/dbt_project && dbt run --profiles-dir .",
    )

    test_dbt_models = BashOperator(
        task_id="test_dbt_models",
        bash_command="cd /opt/airflow/dbt_project && dbt test --profiles-dir .",
    )

    load_yesterday_orders_to_staging >> run_dbt_models >> test_dbt_models
