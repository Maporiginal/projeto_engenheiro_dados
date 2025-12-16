import time
import boto3

REGION = "us-east-1"
DATABASE = "SEU_DATABASE"
OUTPUT = "s3://maporiginal-data-lake-dev-us-east-1-20251215/athena-results/"
SQL = "SELECT * FROM customers LIMIT 10;"

athena = boto3.client("athena", region_name=REGION)

qid = athena.start_query_execution(
    QueryString=SQL,
    QueryExecutionContext={"Database": DATABASE},
    ResultConfiguration={"OutputLocation": OUTPUT},
)["QueryExecutionId"]

while True:
    st = athena.get_query_execution(QueryExecutionId=qid)["QueryExecution"]["Status"]["State"]
    if st in ("SUCCEEDED", "FAILED", "CANCELLED"):
        break
    time.sleep(1)

if st != "SUCCEEDED":
    raise RuntimeError(st)

res = athena.get_query_results(QueryExecutionId=qid, MaxResults=50)["ResultSet"]["Rows"]

header = [c.get("VarCharValue","") for c in res[0]["Data"]]
print(" | ".join(header))
print("-" * 80)

for r in res[1:]:
    vals = [c.get("VarCharValue","") for c in r["Data"]]
    print(" | ".join(vals))
