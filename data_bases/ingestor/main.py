import os
import time
from datetime import datetime, timezone

import psycopg2
from psycopg2.extras import execute_values, Json
import pymysql
from pymongo import MongoClient


def env(name: str, default: str | None = None) -> str:
    v = os.getenv(name)
    if v is None or v == "":
        if default is None:
            raise RuntimeError(f"Variável de ambiente obrigatória não definida: {name}")
        return default
    return v


def utcnow():
    return datetime.now(timezone.utc)


def wait_until_ok(fn, name: str, tries: int = 60, sleep_s: int = 2):
    for i in range(tries):
        try:
            fn()
            print(f"[OK] {name}")
            return
        except Exception as e:
            print(f"[WAIT] {name} ({i+1}/{tries}) -> {e}")
            time.sleep(sleep_s)
    raise RuntimeError(f"{name} não ficou disponível a tempo")


# -----------------------------
# EXTRACT
# -----------------------------
def extract_clients_pg(pg_conn):
    """
    Espera uma tabela: clientes(id, nome, email)
    """
    with pg_conn.cursor() as cur:
        cur.execute("""
            SELECT id::int, nome::text, email::text
            FROM clientes
        """)
        rows = cur.fetchall()
    return {cid: {"cliente_id": cid, "nome": nome, "email": email} for (cid, nome, email) in rows}


def extract_orders_mysql(mysql_conn):
    """
    Espera uma tabela: pedidos(id, cliente_id, valor_total, created_at)
    Retorna agregados por cliente_id.
    """
    sql = """
        SELECT
            cliente_id,
            COUNT(*) AS qtd_pedidos,
            COALESCE(SUM(valor_total), 0) AS total_gasto,
            MAX(created_at) AS ultimo_pedido_em
        FROM pedidos
        GROUP BY cliente_id
    """
    with mysql_conn.cursor() as cur:
        cur.execute(sql)
        rows = cur.fetchall()

    agg = {}
    for (cliente_id, qtd, total, ultimo) in rows:
        agg[int(cliente_id)] = {
            "qtd_pedidos": int(qtd),
            "total_gasto": float(total) if total is not None else 0.0,
            "ultimo_pedido_em": ultimo.isoformat() if ultimo else None,
        }
    return agg


def extract_tickets_mongo(mongo_db):
    """
    Espera coleção: chamados
    Estrutura mínima esperada (exemplo):
      { cliente_id: 1, status: "aberto"|"fechado", interacoes: [{ts: ISODate(...)}, ...] }

    Retorna agregados por cliente_id:
      qtd_chamados_abertos, ultima_interacao_em, raw (lista resumida)
    """
    col = mongo_db["chamados"]
    docs = col.find({}, {"_id": 0, "cliente_id": 1, "status": 1, "interacoes": 1})

    agg = {}
    for d in docs:
        cid = d.get("cliente_id")
        if cid is None:
            continue
        try:
            cid = int(cid)
        except Exception:
            continue

        status = (d.get("status") or "").lower()
        interacoes = d.get("interacoes") or []

        last_ts = None
        for it in interacoes:
            ts = it.get("ts")
            # pymongo costuma devolver datetime
            if isinstance(ts, datetime):
                ts = ts.astimezone(timezone.utc)
            elif isinstance(ts, str):
                try:
                    ts = datetime.fromisoformat(ts.replace("Z", "+00:00"))
                except Exception:
                    ts = None
            else:
                ts = None

            if ts and (last_ts is None or ts > last_ts):
                last_ts = ts

        if cid not in agg:
            agg[cid] = {
                "qtd_chamados_abertos": 0,
                "ultima_interacao_em": None,
                "raw": [],
            }

        if status == "aberto":
            agg[cid]["qtd_chamados_abertos"] += 1

        if last_ts:
            cur_last = agg[cid]["ultima_interacao_em"]
            if cur_last is None or last_ts > cur_last:
                agg[cid]["ultima_interacao_em"] = last_ts

        # guarda um resumão do ticket (pra debug/BI)
        agg[cid]["raw"].append({
            "status": status,
            "ultima_interacao_em": last_ts.isoformat() if last_ts else None
        })

    # normaliza datetime -> iso
    for cid, v in agg.items():
        if isinstance(v["ultima_interacao_em"], datetime):
            v["ultima_interacao_em"] = v["ultima_interacao_em"].isoformat()

    return agg


# -----------------------------
# LOAD (Postgres)
# -----------------------------
def ensure_target_table(pg_conn):
    with pg_conn.cursor() as cur:
        cur.execute("""
            CREATE TABLE IF NOT EXISTS customer_360 (
                cliente_id           INT PRIMARY KEY,
                nome                 TEXT,
                email                TEXT,
                qtd_pedidos          INT,
                total_gasto          NUMERIC(14,2),
                ultimo_pedido_em     TIMESTAMPTZ,
                qtd_chamados_abertos INT,
                ultima_interacao_em  TIMESTAMPTZ,
                suporte_raw          JSONB,
                updated_at           TIMESTAMPTZ NOT NULL
            )
        """)
    pg_conn.commit()


def upsert_customer_360(pg_conn, rows: list[tuple]):
    sql = """
        INSERT INTO customer_360 (
            cliente_id, nome, email,
            qtd_pedidos, total_gasto, ultimo_pedido_em,
            qtd_chamados_abertos, ultima_interacao_em,
            suporte_raw, updated_at
        )
        VALUES %s
        ON CONFLICT (cliente_id) DO UPDATE SET
            nome=EXCLUDED.nome,
            email=EXCLUDED.email,
            qtd_pedidos=EXCLUDED.qtd_pedidos,
            total_gasto=EXCLUDED.total_gasto,
            ultimo_pedido_em=EXCLUDED.ultimo_pedido_em,
            qtd_chamados_abertos=EXCLUDED.qtd_chamados_abertos,
            ultima_interacao_em=EXCLUDED.ultima_interacao_em,
            suporte_raw=EXCLUDED.suporte_raw,
            updated_at=EXCLUDED.updated_at
    """
    with pg_conn.cursor() as cur:
        execute_values(cur, sql, rows, page_size=500)
    pg_conn.commit()


def iso_to_timestamptz(iso: str | None):
    if not iso:
        return None
    try:
        return datetime.fromisoformat(iso.replace("Z", "+00:00"))
    except Exception:
        return None


def main():
    print("[START] Ingestor (customer_360)")
    # Postgres
    pg_host = env("PG_HOST")
    pg_port = int(env("PG_PORT", "5432"))
    pg_db   = env("PG_DB")
    pg_user = env("PG_USER")
    pg_pass = env("PG_PASS")

    # MySQL
    my_host = env("MYSQL_HOST")
    my_port = int(env("MYSQL_PORT", "3306"))
    my_db   = env("MYSQL_DB")
    my_user = env("MYSQL_USER")
    my_pass = env("MYSQL_PASS")

    # Mongo
    mo_host = env("MONGO_HOST")
    mo_port = int(env("MONGO_PORT", "27017"))
    mo_db   = env("MONGO_DB")
    mo_user = env("MONGO_USER")
    mo_pass = env("MONGO_PASS")

    # connections (com waits simples)
    def _pg_try():
        c = psycopg2.connect(host=pg_host, port=pg_port, dbname=pg_db, user=pg_user, password=pg_pass)
        c.close()

    def _my_try():
        c = pymysql.connect(host=my_host, port=my_port, user=my_user, password=my_pass, database=my_db, connect_timeout=3)
        c.close()

    def _mo_try():
        uri = f"mongodb://{mo_user}:{mo_pass}@{mo_host}:{mo_port}/{mo_db}?authSource=admin"
        client = MongoClient(uri, serverSelectionTimeoutMS=3000)
        client.admin.command("ping")
        client.close()

    wait_until_ok(_pg_try, "Postgres")
    wait_until_ok(_my_try, "MySQL")
    wait_until_ok(_mo_try, "Mongo")

    pg_conn = psycopg2.connect(host=pg_host, port=pg_port, dbname=pg_db, user=pg_user, password=pg_pass)
    my_conn = pymysql.connect(host=my_host, port=my_port, user=my_user, password=my_pass, database=my_db)
    mongo_uri = f"mongodb://{mo_user}:{mo_pass}@{mo_host}:{mo_port}/{mo_db}?authSource=admin"
    mongo = MongoClient(mongo_uri)
    mongo_db = mongo[mo_db]

    try:
        ensure_target_table(pg_conn)

        clients = extract_clients_pg(pg_conn)
        orders  = extract_orders_mysql(my_conn)
        tickets = extract_tickets_mongo(mongo_db)

        now = utcnow()
        out_rows = []

        # faz o merge baseado em cliente_id
        all_ids = set(clients.keys()) | set(orders.keys()) | set(tickets.keys())

        for cid in sorted(all_ids):
            c = clients.get(cid, {})
            o = orders.get(cid, {})
            t = tickets.get(cid, {})

            nome = c.get("nome")
            email = c.get("email")

            qtd_pedidos = o.get("qtd_pedidos", 0)
            total_gasto = o.get("total_gasto", 0.0)
            ultimo_pedido_em = iso_to_timestamptz(o.get("ultimo_pedido_em"))

            qtd_chamados_abertos = t.get("qtd_chamados_abertos", 0)
            ultima_interacao_em  = iso_to_timestamptz(t.get("ultima_interacao_em"))
            suporte_raw = t.get("raw", [])

            out_rows.append((
                cid,
                nome,
                email,
                int(qtd_pedidos),
                total_gasto,
                ultimo_pedido_em,
                int(qtd_chamados_abertos),
                ultima_interacao_em,
                Json(suporte_raw),
                now
            ))

        upsert_customer_360(pg_conn, out_rows)

        print(f"[DONE] upsert customer_360: {len(out_rows)} registros")
        # mantém vivo (pra você ver logs / container “verde”)
        while True:
            time.sleep(60)

    finally:
        try:
            my_conn.close()
        except Exception:
            pass
        try:
            pg_conn.close()
        except Exception:
            pass
        try:
            mongo.close()
        except Exception:
            pass


if __name__ == "__main__":
    main()
