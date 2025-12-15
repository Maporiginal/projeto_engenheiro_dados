import os
import io
import json
from datetime import datetime, timezone

import psycopg2
import pymysql
from pymongo import MongoClient

import boto3
import pandas as pd


def env(name: str, default: str | None = None) -> str:
    v = os.getenv(name)
    if not v:
        if default is None:
            raise RuntimeError(f"Variável obrigatória não definida: {name}")
        return default
    return v


def utcnow():
    return datetime.now(timezone.utc)


def parquet_bytes(df: pd.DataFrame) -> io.BytesIO:
    # deixa datas/UUIDs bem “parquet-friendly”
    for c in df.columns:
        df[c] = df[c].apply(lambda x: x.isoformat() if isinstance(x, datetime) else x)
    buf = io.BytesIO()
    df.to_parquet(buf, index=False, engine="pyarrow")
    buf.seek(0)
    return buf


def s3_key(source: str, entity: str, ingestion_date: str, run_id: str) -> str:
    return f"raw/{source}/{entity}/ingestion_date={ingestion_date}/run_id={run_id}/part-0000.parquet"


def upload_df(s3, bucket: str, key: str, df: pd.DataFrame):
    s3.upload_fileobj(parquet_bytes(df), bucket, key)
    print(f"[S3] {key} ({len(df)} linhas)")


def main():
    bucket = env("S3_BUCKET")
    region = env("AWS_REGION", "us-east-1")
    s3 = boto3.client("s3", region_name=region)

    ingestion_date = utcnow().date().isoformat()
    run_id = utcnow().strftime("%Y%m%dT%H%M%SZ")

    # -------- Postgres --------
    pg = psycopg2.connect(
        host=env("PG_HOST"),
        port=int(env("PG_PORT", "5432")),
        dbname=env("PG_DB"),
        user=env("PG_USER"),
        password=env("PG_PASS"),
    )

    # -------- MySQL --------
    my = pymysql.connect(
        host=env("MYSQL_HOST"),
        port=int(env("MYSQL_PORT", "3306")),
        database=env("MYSQL_DB"),
        user=env("MYSQL_USER"),
        password=env("MYSQL_PASS"),
    )

    # -------- Mongo --------
    mongo_uri = (
        f"mongodb://{env('MONGO_USER')}:{env('MONGO_PASS')}"
        f"@{env('MONGO_HOST')}:{int(env('MONGO_PORT', '27017'))}/{env('MONGO_DB')}?authSource=admin"
    )
    mo = MongoClient(mongo_uri)
    mo_db = mo[env("MONGO_DB")]

    try:
        # 1) Postgres -> customers
        with pg.cursor() as cur:
            cur.execute("""
                SELECT
                  customer_id::text AS customer_id,
                  full_name::text   AS full_name,
                  email::text       AS email,
                  created_at        AS created_at
                FROM financeiro.customers
            """)
            rows = cur.fetchall()
        df = pd.DataFrame(rows, columns=["customer_id", "full_name", "email", "created_at"])
        upload_df(s3, bucket, s3_key("financeiro", "customers", ingestion_date, run_id), df)

        # 2) Postgres -> ledger
        with pg.cursor() as cur:
            cur.execute("""
                SELECT
                  ledger_id::text   AS ledger_id,
                  customer_id::text AS customer_id,
                  kind::text        AS kind,
                  amount            AS amount,
                  ref::text         AS ref,
                  created_at        AS created_at
                FROM financeiro.ledger
            """)
            rows = cur.fetchall()
        df = pd.DataFrame(rows, columns=["ledger_id", "customer_id", "kind", "amount", "ref", "created_at"])
        upload_df(s3, bucket, s3_key("financeiro", "ledger", ingestion_date, run_id), df)

        # 3) MySQL -> orders/pedidos (tenta os dois nomes)
        with my.cursor() as cur:
            try:
                cur.execute("SELECT * FROM orders")
                rows = cur.fetchall()
                cols = [d[0] for d in cur.description]
                df = pd.DataFrame(rows, columns=cols)
                upload_df(s3, bucket, s3_key("vendas", "orders", ingestion_date, run_id), df)
            except Exception:
                cur.execute("SELECT * FROM pedidos")
                rows = cur.fetchall()
                cols = [d[0] for d in cur.description]
                df = pd.DataFrame(rows, columns=cols)
                upload_df(s3, bucket, s3_key("vendas", "pedidos", ingestion_date, run_id), df)

        # 4) Mongo -> tickets/chamados (tenta os dois nomes)
        cols = mo_db.list_collection_names()
        colname = "tickets" if "tickets" in cols else "chamados"

        docs = list(mo_db[colname].find({}, {"_id": 0}))
        df = pd.DataFrame([{"document_json": json.dumps(d, ensure_ascii=False, default=str)} for d in docs])
        upload_df(s3, bucket, s3_key("suporte", colname, ingestion_date, run_id), df)

        print("[DONE] RAW enviado para o S3")

    finally:
        try: pg.close()
        except: pass
        try: my.close()
        except: pass
        try: mo.close()
        except: pass


if __name__ == "__main__":
    main()
