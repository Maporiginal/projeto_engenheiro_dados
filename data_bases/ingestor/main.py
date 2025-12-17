#!/usr/bin/env python3
# main.py - Ingestão RAW (Postgres + MySQL + Mongo) -> S3 (Parquet) + manifest
import os
import io
import json
from datetime import datetime, timezone, date
from decimal import Decimal

import boto3
import pandas as pd
import psycopg2
import pymysql
from pymongo import MongoClient


# ---------------------------
# Helpers
# ---------------------------
def env(name: str, default: str | None = None) -> str:
    v = os.getenv(name)
    if v is None or v == "":
        if default is None:
            raise RuntimeError(f"Variável obrigatória não definida: {name}")
        return default
    return v


def env_first(*names: str, default: str | None = None) -> str:
    """Retorna o primeiro env existente (não vazio) dentre os nomes informados."""
    for n in names:
        v = os.getenv(n)
        if v is not None and v != "":
            return v
    if default is None:
        raise RuntimeError(f"Nenhuma das variáveis foi definida: {', '.join(names)}")
    return default


def utcnow() -> datetime:
    return datetime.now(timezone.utc)


def s3_key(source: str, entity: str, ingestion_date: str, run_id: str) -> str:
    return f"raw/{source}/{entity}/ingestion_date={ingestion_date}/run_id={run_id}/part-0000.parquet"


def manifest_key(ingestion_date: str, run_id: str) -> str:
    return f"raw/_manifests/ingestion_date={ingestion_date}/run_id={run_id}/manifest.json"


def to_parquet_bytes(df: pd.DataFrame) -> io.BytesIO:
    buf = io.BytesIO()
    df.to_parquet(buf, index=False, engine="pyarrow")
    buf.seek(0)
    return buf


def _fix_scalar(x):
    if x is None:
        return None
    if isinstance(x, (datetime, date)):
        if isinstance(x, datetime):
            if x.tzinfo is None:
                x = x.replace(tzinfo=timezone.utc)
            return x.astimezone(timezone.utc).isoformat()
        return x.isoformat()
    if isinstance(x, Decimal):
        return float(x)
    return x


def normalize_df(df: pd.DataFrame) -> pd.DataFrame:
    out = df.copy()
    for c in out.columns:
        out[c] = out[c].map(_fix_scalar)
    return out


def upload_df(s3, bucket: str, key: str, df: pd.DataFrame) -> int:
    df = normalize_df(df)
    s3.upload_fileobj(to_parquet_bytes(df), bucket, key)
    return len(df)


def delete_prefix(s3, bucket: str, prefix: str) -> None:
    paginator = s3.get_paginator("list_objects_v2")
    batch = []
    for page in paginator.paginate(Bucket=bucket, Prefix=prefix):
        for obj in page.get("Contents", []):
            batch.append({"Key": obj["Key"]})
            if len(batch) == 1000:
                s3.delete_objects(Bucket=bucket, Delete={"Objects": batch})
                batch.clear()
    if batch:
        s3.delete_objects(Bucket=bucket, Delete={"Objects": batch})


def json_safe(obj):
    if isinstance(obj, (datetime, date)):
        return obj.isoformat()
    if isinstance(obj, Decimal):
        return float(obj)
    if isinstance(obj, dict):
        return {k: json_safe(v) for k, v in obj.items()}
    if isinstance(obj, list):
        return [json_safe(v) for v in obj]
    return obj


# ---------------------------
# Main
# ---------------------------
def main():
    # ---- AWS / S3 ----
    bucket = env("S3_BUCKET")
    region = env("AWS_REGION", "us-east-1")
    s3 = boto3.client("s3", region_name=region)

    if env("CLEANUP", "false").lower() == "true":
        delete_prefix(s3, bucket, "raw/")
        delete_prefix(s3, bucket, "curated/")
        delete_prefix(s3, bucket, "athena-results/")

    ingestion_date = utcnow().date().isoformat()
    run_id = utcnow().strftime("%Y%m%dT%H%M%SZ")

    # ---- Postgres ----
    pg = psycopg2.connect(
        host=env("PG_HOST"),
        port=int(env("PG_PORT", "5432")),
        dbname=env("PG_DB"),
        user=env("PG_USER"),
        password=env("PG_PASS"),
    )

    # ---- MySQL ----
    my = pymysql.connect(
        host=env("MYSQL_HOST"),
        port=int(env("MYSQL_PORT", "3306")),
        database=env("MYSQL_DB"),
        user=env("MYSQL_USER"),
        password=env("MYSQL_PASS"),
    )

    # ---- Mongo ----
    mongo_uri = (
                f"mongodb://{env('MONGO_ROOT_PASS')}:{env('MONGO_ROOT_PASS')}"
                f"@{env('MONGO_HOST')}:{int(env('MONGO_PORT','27017'))}/{env('MONGO_DB')}"
    )
    mo = MongoClient(mongo_uri)
    mo_db = mo[env("MONGO_DB")]

    manifest = {
        "bucket": bucket,
        "region": region,
        "ingestion_date": ingestion_date,
        "run_id": run_id,
        "datasets": [],
        "created_at_utc": utcnow().isoformat(),
    }

    try:
        # -------------------------
        # POSTGRES: financeiro.customers
        # -------------------------
        with pg.cursor() as cur:
            cur.execute(
                """
                SELECT
                    customer_id::text AS customer_id,
                    full_name,
                    email,
                    phone,
                    city,
                    state,
                    created_at::text AS created_at
                FROM financeiro.customers
                ORDER BY created_at
                """
            )
            rows = cur.fetchall()

        df = pd.DataFrame(rows, columns=["customer_id", "full_name", "email", "phone", "city", "state", "created_at"])
        key = s3_key("financeiro", "customers", ingestion_date, run_id)
        n = upload_df(s3, bucket, key, df)
        print(f"[S3] {key} ({n} linhas)")
        manifest["datasets"].append({"source": "financeiro", "entity": "customers", "rows": n, "key": key})

        # -------------------------
        # POSTGRES: financeiro.ledger
        # -------------------------
        with pg.cursor() as cur:
            cur.execute(
                """
                SELECT
                    ledger_id::text AS ledger_id,
                    customer_id::text AS customer_id,
                    entry_ts::text AS entry_ts,
                    entry_type,
                    amount,
                    description
                FROM financeiro.ledger
                ORDER BY entry_ts
                """
            )
            rows = cur.fetchall()

        df = pd.DataFrame(rows, columns=["ledger_id", "customer_id", "entry_ts", "entry_type", "amount", "description"])
        key = s3_key("financeiro", "ledger", ingestion_date, run_id)
        n = upload_df(s3, bucket, key, df)
        print(f"[S3] {key} ({n} linhas)")
        manifest["datasets"].append({"source": "financeiro", "entity": "ledger", "rows": n, "key": key})

        # -------------------------
        # MYSQL: vendas.orders
        # -------------------------
        with my.cursor() as cur:
            cur.execute(
                """
                SELECT
                    order_id,
                    customer_id,
                    order_ts,
                    status,
                    total,
                    currency,
                    payment_method,
                    sales_channel
                FROM orders
                ORDER BY order_ts
                """
            )
            rows = cur.fetchall()

        df = pd.DataFrame(
            rows,
            columns=["order_id", "customer_id", "order_ts", "status", "total", "currency", "payment_method", "sales_channel"],
        )
        key = s3_key("vendas", "orders", ingestion_date, run_id)
        n = upload_df(s3, bucket, key, df)
        print(f"[S3] {key} ({n} linhas)")
        manifest["datasets"].append({"source": "vendas", "entity": "orders", "rows": n, "key": key})

        # -------------------------
        # MYSQL: vendas.order_items
        # -------------------------
        with my.cursor() as cur:
            cur.execute(
                """
                SELECT
                    order_item_id,
                    order_id,
                    sku,
                    product_name,
                    quantity,
                    unit_price,
                    line_total
                FROM order_items
                ORDER BY order_item_id
                """
            )
            rows = cur.fetchall()

        df = pd.DataFrame(
            rows,
            columns=["order_item_id", "order_id", "sku", "product_name", "quantity", "unit_price", "line_total"],
        )
        key = s3_key("vendas", "order_items", ingestion_date, run_id)
        n = upload_df(s3, bucket, key, df)
        print(f"[S3] {key} ({n} linhas)")
        manifest["datasets"].append({"source": "vendas", "entity": "order_items", "rows": n, "key": key})

        # -------------------------
        # MONGO: suporte.tickets (simplificado)
        # - order_id vem de related.order_id
        # - events é array -> events_json (string)
        # -------------------------
        docs = list(mo_db["tickets"].find({}, {"_id": 0}))

        out = []
        for d in docs:
            d = json_safe(d)
            related = d.get("related") or {}
            events = d.get("events") or []

            out.append(
                {
                    "ticket_id": d.get("ticket_id"),
                    "customer_id": d.get("customer_id"),
                    "order_id": related.get("order_id"),
                    "status": d.get("status"),
                    "created_at": d.get("created_at"),
                    "updated_at": d.get("updated_at"),
                    "events_json": json.dumps(events, ensure_ascii=False),
                    "document_json": json.dumps(d, ensure_ascii=False),
                }
            )

        df = pd.DataFrame(
            out,
            columns=["ticket_id", "customer_id", "order_id", "status", "created_at", "updated_at", "events_json", "document_json"],
        )
        key = s3_key("suporte", "tickets", ingestion_date, run_id)
        n = upload_df(s3, bucket, key, df)
        print(f"[S3] {key} ({n} linhas)")
        manifest["datasets"].append({"source": "suporte", "entity": "tickets", "rows": n, "key": key})

        # -------------------------
        # MANIFEST
        # -------------------------
        mkey = manifest_key(ingestion_date, run_id)
        s3.put_object(
            Bucket=bucket,
            Key=mkey,
            Body=json.dumps(manifest, ensure_ascii=False, indent=2).encode("utf-8"),
            ContentType="application/json",
        )
        print(f"[S3] {mkey} (manifest)")
        print("[DONE] RAW enviado para o S3")

    finally:
        try:
            pg.close()
        except Exception:
            pass
        try:
            my.close()
        except Exception:
            pass
        try:
            mo.close()
        except Exception:
            pass


if __name__ == "__main__":
    main()
