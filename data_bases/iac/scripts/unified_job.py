import sys
from datetime import datetime, timezone

from pyspark.context import SparkContext
from pyspark.sql import functions as F

from awsglue.context import GlueContext
from awsglue.job import Job
from awsglue.utils import getResolvedOptions

args = getResolvedOptions(sys.argv, ["JOB_NAME", "S3_BUCKET"])

bucket = args["S3_BUCKET"]

sc = SparkContext.getOrCreate()
glueContext = GlueContext(sc)
spark = glueContext.spark_session

job = Job(glueContext)
job.init(args["JOB_NAME"], args)

ingestion_date = datetime.now(timezone.utc).strftime("%Y-%m-%d")
run_id = datetime.now(timezone.utc).strftime("%Y%m%dT%H%M%SZ")

def read_parquet(prefix: str):
    path = f"s3://{bucket}/{prefix}"
    df = spark.read.parquet(path)
    print(f"[INFO] Lido {path} | linhas={df.count()} | colunas={len(df.columns)}")
    return df

customers = read_parquet("raw/financeiro/customers/")
orders    = read_parquet("raw/vendas/orders/")
tickets   = read_parquet("raw/suporte/tickets/")

def require_cols(df, cols, name):
    missing = [c for c in cols if c not in df.columns]
    if missing:
        raise Exception(f"[ERRO] Dataset {name} sem colunas obrigatórias: {missing}. Colunas atuais: {df.columns}")

require_cols(customers, ["customer_id", "full_name"], "customers")
require_cols(orders, ["customer_id", "total"], "orders")
require_cols(tickets, ["customer_id", "created_at"], "tickets")

orders  = orders.withColumn("total", F.col("total").cast("double"))
tickets = tickets.withColumn("created_at_ts", F.to_timestamp("created_at"))

orders_agg = (
    orders.groupBy("customer_id")
          .agg(F.count("*").alias("total_pedidos"),
               F.sum("total").alias("valor_total"))
)

tickets_agg = (
    tickets.groupBy("customer_id")
           .agg(F.count("*").alias("qtde_chamados"),
                F.max("created_at_ts").alias("ultima_interacao"))
)

final_df = (
    customers.join(orders_agg, "customer_id", "left")
             .join(tickets_agg, "customer_id", "left")
             .select(
                 F.col("customer_id").alias("id_cliente"),
                 F.col("full_name").alias("nome"),
                 F.coalesce(F.col("total_pedidos"), F.lit(0)).alias("total_pedidos"),
                 F.coalesce(F.col("valor_total"), F.lit(0.0)).alias("valor_total"),
                 F.coalesce(F.col("qtde_chamados"), F.lit(0)).alias("qtde_chamados"),
                 F.col("ultima_interacao")
             )
)

out_path = f"s3://{bucket}/curated/clientes_unificados/ingestion_date={ingestion_date}/run_id={run_id}/"
final_df.write.mode("overwrite").parquet(out_path)
print(f"[OK] Curated gerado em: {out_path}")

job.commit()
