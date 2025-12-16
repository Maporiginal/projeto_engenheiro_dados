import time
import boto3

REGION = "us-east-1"
DATABASE = "metadata-database"
OUTPUT = "s3://maporiginal-data-lake-dev-us-east-1-20251215/athena-results/"
SQL = "SELECT * FROM customers LIMIT 10;"

athena = boto3.client("athena", region_name=REGION)

qid = athena.start_query_execution(
    QueryString=SQL,
    QueryExecutionContext={"Database": DATABASE},
    ResultConfiguration={"OutputLocation": OUTPUT},
)["QueryExecutionId"]

while True:
    qe = athena.get_query_execution(QueryExecutionId=qid)["QueryExecution"]
    st = qe["Status"]["State"]
    if st in ("SUCCEEDED", "FAILED", "CANCELLED"):
        break
    time.sleep(1)

if st != "SUCCEEDED":
    raise RuntimeError(f"{st}: {qe['Status'].get('StateChangeReason','')}")

# Metadados essenciais
stats = qe.get("Statistics", {})
print("QueryExecutionId:", qid)
print("DataScannedInBytes:", stats.get("DataScannedInBytes"))
print("OutputLocation:", qe["ResultConfiguration"]["OutputLocation"])
print("-" * 80)

# Dados
rows = athena.get_query_results(QueryExecutionId=qid, MaxResults=50)["ResultSet"]["Rows"]

header = [c.get("VarCharValue", "") for c in rows[0]["Data"]]
print(" | ".join(header))
print("-" * 80)

for r in rows[1:]:
    vals = [c.get("VarCharValue", "") for c in r["Data"]]
    print(" | ".join(vals))
