import os
import json
import time
import re
import boto3

ATHENA_DB = os.environ["ATHENA_DATABASE"]
ATHENA_TABLE = os.environ["ATHENA_TABLE"]
ATHENA_OUTPUT = os.environ["ATHENA_OUTPUT"]  # ex: s3://bucket/athena-results/
ATHENA_WORKGROUP = os.environ.get("ATHENA_WORKGROUP", "primary")

athena = boto3.client("athena")


def _resp(status: int, body: dict):
    return {
        "statusCode": status,
        "headers": {"Content-Type": "application/json"},
        "body": json.dumps(body, ensure_ascii=False),
    }


def _sanitize_like(s: str) -> str:
    # Mantém simples e evita bagunça de SQL injection:
    # - remove chars estranhos
    # - escapa aspas simples
    s = (s or "").strip()
    s = re.sub(r"[^0-9A-Za-zÀ-ÿ _\-\.\@]", "", s)
    return s.replace("'", "''")


def lambda_handler(event, context):
    qs = (event.get("queryStringParameters") or {})
    nome = qs.get("nome")

    if not nome:
        return _resp(400, {"error": "Parâmetro obrigatório: nome"})

    nome = _sanitize_like(nome)
    if not nome:
        return _resp(400, {"error": "Parâmetro nome inválido após sanitização"})

    sql = f"""
    SELECT
      id_cliente,
      nome,
      total_pedidos,
      valor_total,
      qtde_chamados,
      CAST(ultima_interacao AS varchar) AS ultima_interacao
    FROM {ATHENA_TABLE}
    WHERE lower(nome) LIKE lower('%{nome}%')
    ORDER BY valor_total DESC
    LIMIT 50
    """

    qid = athena.start_query_execution(
        QueryString=sql,
        QueryExecutionContext={"Database": ATHENA_DB},
        ResultConfiguration={"OutputLocation": ATHENA_OUTPUT},
        WorkGroup=ATHENA_WORKGROUP,
    )["QueryExecutionId"]

    # polling simples (dataset pequeno)
    deadline = time.time() + 25
    state = "RUNNING"
    while time.time() < deadline:
        qe = athena.get_query_execution(QueryExecutionId=qid)["QueryExecution"]
        state = qe["Status"]["State"]
        if state in ("SUCCEEDED", "FAILED", "CANCELLED"):
            break
        time.sleep(0.7)

    if state != "SUCCEEDED":
        reason = qe["Status"].get("StateChangeReason", "")
        return _resp(504, {"error": "Athena query não finalizou com sucesso", "state": state, "reason": reason})

    res = athena.get_query_results(QueryExecutionId=qid, MaxResults=1000)
    rows = res["ResultSet"]["Rows"]

    if len(rows) <= 1:
        return _resp(200, {"items": []})

    headers = [c.get("VarCharValue") for c in rows[0]["Data"]]
    items = []
    for r in rows[1:]:
        data = r.get("Data", [])
        values = [(c.get("VarCharValue") if c else None) for c in data]
        # garante mesmo tamanho do header
        values += [None] * (len(headers) - len(values))
        items.append(dict(zip(headers, values)))

    return _resp(200, {"items": items})
