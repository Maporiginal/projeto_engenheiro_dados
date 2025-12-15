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


def to_parquet_bytes(df: pd.DataFrame) -> io.BytesIO:
    buf = io.BytesIO()
    df.to_parquet(buf, index=False, engine="pyarrow")
    buf.seek(0)
    return buf


def s3_key(source: str, entity: str, ingestion_date: str, run_id: str) -> str:
    return f"raw/{source}/{entity}/ingestion_date={ingestion_date}/run_id={run_id}/part-0000.parquet"


def main():
    # ---- AWS/S3 ----
    bucket = env("S3_BUCKET")
    region = env("AWS_REGION", "us-east-1")
    s3 = boto3.client("s3", region_name=region)

    ingestion_date = utcnow().date().isoformat()
    run_id = utcnow().strftime("%Y%m%dT%H%M%SZ")

    # ---- Postgres ----
    pg = psycopg2.connect(
        host=env("PG_HOST"), port=int(env("PG_PORT", "15432")),
        dbname=env("PG_DB"), user=env("PG_USER"), password=env("PG_PASS")
    )

    # ---- MySQL ----
    my = pymysql.connect(
        host=env("MYSQL_HOST"), port=int(env("MYSQL_PORT", "13306")),
        database=env("MYSQL_DB"), user=env("MYSQL_USER"), password=env("MYSQL_PASS")
    )

    # ---- Mongo ----
    mongo_uri = f"mongodb://{env('MONGO_USER')}:{env('MONGO_PASS')}@{env('MONGO_HOST')}:{int(env('MONGO_PORT','27017'))}/{env('MONGO_DB')}?authSource=admin"
    mo = MongoClient(mongo_uri)
    mo_db = mo[env("MONGO_DB")]

    try:
        # 1) clientes (Postgres)
        with pg.cursor() as cur:
            cur.execute("SELECT id::int AS cliente_id, nome::text, email::text FROM clientes")
            rows = cur.fetchall()
        df_clients = pd.DataFrame(rows, columns=["cliente_id", "nome", "email"])
        key = s3_key("financeiro", "clientes", ingestion_date, run_id)
        s3.upload_fileobj(to_parquet_bytes(df_clients), bucket, key)
        print(f"[S3] {key} ({len(df_clients)} linhas)")

        # 2) pedidos (MySQL)
        with my.cursor() as cur:
            cur.execute("SELECT id, cliente_id, valor_total, created_at FROM pedidos")
            rows = cur.fetchall()
        df_orders = pd.DataFrame(rows, columns=["order_id", "cliente_id", "valor_total", "created_at"])
        # normaliza datetime -> string ISO (evita dor)
        if "created_at" in df_orders.columns:
            df_orders["created_at"] = df_orders["created_at"].apply(lambda x: x.isoformat() if x else None)

        key = s3_key("vendas", "pedidos", ingestion_date, run_id)
        s3.upload_fileobj(to_parquet_bytes(df_orders), bucket, key)
        print(f"[S3] {key} ({len(df_orders)} linhas)")

        # 3) chamados (Mongo) - guarda documento inteiro como JSON string
        docs = list(mo_db["chamados"].find({}, {"_id": 0}))
        for d in docs:
            # converte datetimes (se houver)
            for k, v in list(d.items()):
                if isinstance(v, datetime):
                    d[k] = v.astimezone(timezone.utc).isoformat()

        df_tickets = pd.DataFrame([{
            "cliente_id": d.get("cliente_id"),
            "status": d.get("status"),
            "document_json": json.dumps(d, ensure_ascii=False)
        } for d in docs])

        key = s3_key("suporte", "chamados", ingestion_date, run_id)
        s3.upload_fileobj(to_parquet_bytes(df_tickets), bucket, key)
        print(f"[S3] {key} ({len(df_tickets)} linhas)")

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
