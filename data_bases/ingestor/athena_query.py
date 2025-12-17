import time
import boto3


REGION = "us-east-1"
DATABASE = "metadata-database-raw-curated"
OUTPUT = "s3://maporiginal-data-lake-dev-us-east-1-20251215/athena-results/"

# Prefixo do curated gerado pelo seu job
CURATED_S3_PREFIX = "s3://maporiginal-data-lake-dev-us-east-1-20251215/curated/clientes_unificados/"

POLL_SECONDS = 2
TIMEOUT_SECONDS = 5 * 60  # 5 min


def wait_query(athena_client, qid: str) -> dict:
    start = time.time()
    while True:
        qe = athena_client.get_query_execution(QueryExecutionId=qid)["QueryExecution"]
        st = qe["Status"]["State"]

        if st in ("SUCCEEDED", "FAILED", "CANCELLED"):
            return qe

        if time.time() - start > TIMEOUT_SECONDS:
            raise TimeoutError(f"Timeout esperando query {qid} (>{TIMEOUT_SECONDS}s).")

        time.sleep(POLL_SECONDS)


def fetch_rows(athena_client, qid: str, max_rows: int = 50) -> list:
    rows = []
    token = None

    while True:
        kwargs = {"QueryExecutionId": qid, "MaxResults": min(1000, max_rows - len(rows))}
        if token:
            kwargs["NextToken"] = token

        rs = athena_client.get_query_results(**kwargs)
        rows.extend(rs["ResultSet"]["Rows"])

        token = rs.get("NextToken")
        if not token or len(rows) >= max_rows:
            return rows[:max_rows]


def find_curated_table(glue_client) -> str:
    """
    Procura no Glue Data Catalog (DATABASE) qual tabela aponta para o prefixo curated.
    """
    paginator = glue_client.get_paginator("get_tables")

    for page in paginator.paginate(DatabaseName=DATABASE):
        for t in page.get("TableList", []):
            sd = t.get("StorageDescriptor", {})
            loc = (sd.get("Location") or "").rstrip("/") + "/"
            if loc == CURATED_S3_PREFIX.rstrip("/") + "/":
                return t["Name"]

    raise RuntimeError(
        f"Nenhuma tabela no database '{DATABASE}' com Location = {CURATED_S3_PREFIX}. "
        f"Verifique se o crawler curated rodou e se o prefixo está correto."
    )


def main() -> None:
    glue = boto3.client("glue", region_name=REGION)
    athena = boto3.client("athena", region_name=REGION)

    curated_table = find_curated_table(glue)
    sql = f"SELECT * FROM {curated_table} LIMIT 10;"

    print(f"Consultando tabela curated: {DATABASE}.{curated_table}")
    print(f"SQL: {sql}")

    qid = athena.start_query_execution(
        QueryString=sql,
        QueryExecutionContext={"Database": DATABASE},
        ResultConfiguration={"OutputLocation": OUTPUT},
    )["QueryExecutionId"]

    qe = wait_query(athena, qid)
    st = qe["Status"]["State"]

    if st != "SUCCEEDED":
        reason = qe["Status"].get("StateChangeReason", "")
        raise RuntimeError(f"{st}: {reason}")

    stats = qe.get("Statistics", {})
    print("QueryExecutionId:", qid)
    print("DataScannedInBytes:", stats.get("DataScannedInBytes"))
    print("OutputLocation:", qe["ResultConfiguration"]["OutputLocation"])
    print("-" * 80)

    rows = fetch_rows(athena, qid, max_rows=50)

    if not rows:
        print("(sem resultados)")
        return

    header = [c.get("VarCharValue", "") for c in rows[0].get("Data", [])]
    print(" | ".join(header))
    print("-" * 80)

    for r in rows[1:]:
        vals = [c.get("VarCharValue", "") for c in r.get("Data", [])]
        print(" | ".join(vals))


if __name__ == "__main__":
    main()
