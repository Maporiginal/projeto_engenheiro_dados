import os
import io
import json
from datetime import datetime, timezone
from decimal import Decimal

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


def to_parquet_bytes(df: pd.DataFrame) -> io.BytesIO:
    buf = io.BytesIO()
    df.to_parquet(buf, index=False, engine="pyarrow")
    buf.seek(0)
    return buf


def s3_key(source: str, entity: str, ingestion_date: str, run_id: str) -> str:
    return f"raw/{source}/{entity}/ingestion_date={ingestion_date}/run_id={run_id}/part-0000.parquet"


def manifest_key(ingestion_date: str, run_id: str) -> str:
    return f"raw/_manifests/ingestion_date={ingestion_date}/run_id={run_id}/manifest.json"


def json_safe(obj):
    """Converte datetime/Decimal e estruturas aninhadas para algo serializável em JSON."""
    if isinstance(obj, datetime):
        return obj.astimezone(timezone.utc).isoformat()
    if isinstance(obj, Decimal):
        return float(obj)
    if isinstance(obj, dict):
        return {k: json_safe(v) for k, v in obj.items()}
    if isinstance(obj, list):
        return [json_safe(v) for v in obj]
    return obj


def normalize_df(df: pd.DataFrame) -> pd.DataFrame:
    """Normaliza tipos problemáticos para Parquet (datetime/Decimal/UUID etc.)."""
    for col in df.columns:
        # datetime -> ISO string
        if df[col].dtype == "datetime64[ns]" or df[col].dtype == "datetime64[ns, UTC]":
            df[col] = df[col].apply(lambda x: x.isoformat() if pd.notna(x) else None)

        # objetos mistos: tenta converter datetimes/decimals
        if df[col].dtype == "object":
            def _fix(x):
                if x is None:
                    return None
                if isinstance(x, datetime):
                    return x.astimezone(timezone.utc).isoformat()
                if isinstance(x, Decimal):
                    return float(x)
                return x
            df[col] = df[col].map(_fix)

    return df


def upload_df(s3, bucket: str, key: str, df: pd.DataFrame) -> int:
    df = normalize_df(df)
    s3.upload_fileobj(to_parquet_bytes(df), bucket, key)
    return len(df)


def main():
    # ---- AWS/S3 ----
    bucket = env("S3_BUCKET")
    region = env("AWS_REGION", "us-east-1")
    s3 = boto3.client("s3", region_name=region)

    ingestion_date = utcnow().date().isoformat()
    run_id = utcnow().strftime("%Y%m%dT%H%M%SZ")

    # ---- Postgres ---- (dentro da rede docker: porta 5432)
    pg = psycopg2.connect(
        host=env("PG_HOST"),
        port=int(env("PG_PORT", "5432")),
        dbname=env("PG_DB"),
        user=env("PG_USER"),
        password=env("PG_PASS"),
    )

    # ---- MySQL ---- (dentro da rede docker: porta 3306)
    my = pymysql.connect(
        host=env("MYSQL_HOST"),
        port=int(env("MYSQL_PORT", "3306")),
        database=env("MYSQL_DB"),
        user=env("MYSQL_USER"),
        password=env("MYSQL_PASS"),
    )

    # ---- Mongo ----
    mongo_uri = (
        f"mongodb://{env('MONGO_USER')}:{env('MONGO_PASS')}"
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
            cur.execute("""
                SELECT
                    customer_id::text AS customer_id,
                    full_name,
                    email,
                    created_at
                FROM financeiro.customers
                ORDER BY created_at
            """)
            rows = cur.fetchall()

        df = pd.DataFrame(rows, columns=["customer_id", "full_name", "email", "created_at"])
        key = s3_key("financeiro", "customers", ingestion_date, run_id)
        n = upload_df(s3, bucket, key, df)
        print(f"[S3] {key} ({n} linhas)")
        manifest["datasets"].append({"source": "financeiro", "entity": "customers", "rows": n, "key": key})

        # -------------------------
        # POSTGRES: financeiro.ledger
        # -------------------------
        with pg.cursor() as cur:
            cur.execute("""
                SELECT
                    ledger_id::text AS ledger_id,
                    customer_id::text AS customer_id,
                    kind,
                    amount,
                    ref,
                    created_at
                FROM financeiro.ledger
                ORDER BY created_at
            """)
            rows = cur.fetchall()

        df = pd.DataFrame(rows, columns=["ledger_id", "customer_id", "kind", "amount", "ref", "created_at"])
        key = s3_key("financeiro", "ledger", ingestion_date, run_id)
        n = upload_df(s3, bucket, key, df)
        print(f"[S3] {key} ({n} linhas)")
        manifest["datasets"].append({"source": "financeiro", "entity": "ledger", "rows": n, "key": key})

        # -------------------------
        # MYSQL: vendas.orders
        # -------------------------
        with my.cursor() as cur:
            cur.execute("""
                SELECT
                    order_id,
                    customer_id,
                    status,
                    total,
                    created_at
                FROM orders
                ORDER BY created_at
            """)
            rows = cur.fetchall()

        df = pd.DataFrame(rows, columns=["order_id", "customer_id", "status", "total", "created_at"])
        key = s3_key("vendas", "orders", ingestion_date, run_id)
        n = upload_df(s3, bucket, key, df)
        print(f"[S3] {key} ({n} linhas)")
        manifest["datasets"].append({"source": "vendas", "entity": "orders", "rows": n, "key": key})

        # -------------------------
        # MYSQL: vendas.order_items
        # -------------------------
        with my.cursor() as cur:
            cur.execute("""
                SELECT
                    order_item_id,
                    order_id,
                    sku,
                    qty,
                    unit_price
                FROM order_items
                ORDER BY order_item_id
            """)
            rows = cur.fetchall()

        df = pd.DataFrame(rows, columns=["order_item_id", "order_id", "sku", "qty", "unit_price"])
        key = s3_key("vendas", "order_items", ingestion_date, run_id)
        n = upload_df(s3, bucket, key, df)
        print(f"[S3] {key} ({n} linhas)")
        manifest["datasets"].append({"source": "vendas", "entity": "order_items", "rows": n, "key": key})

        # -------------------------
        # MONGO: suporte.tickets
        # -------------------------
        docs = list(mo_db["tickets"].find({}, {"_id": 0}))

        # grava “raw” do documento inteiro (inclui interactions)
        out = []
        for d in docs:
            d = json_safe(d)
            out.append({
                "ticket_id": d.get("ticket_id"),
                "customer_id": d.get("customer_id"),
                "status": d.get("status"),
                "created_at": d.get("created_at"),
                "document_json": json.dumps(d, ensure_ascii=False),
            })

        df = pd.DataFrame(out, columns=["ticket_id", "customer_id", "status", "created_at", "document_json"])
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
