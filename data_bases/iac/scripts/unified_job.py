import sys
from datetime import datetime, timezone

from pyspark.context import SparkContext
from pyspark.sql import functions as F
from pyspark.sql.types import StructType, StructField, StringType, ArrayType

from awsglue.context import GlueContext
from awsglue.job import Job
from awsglue.utils import getResolvedOptions


# --------------------
# Args / Spark / Glue
# --------------------
args = getResolvedOptions(sys.argv, ["JOB_NAME", "S3_BUCKET"])
bucket = args["S3_BUCKET"]

sc = SparkContext.getOrCreate()
glueContext = GlueContext(sc)
spark = glueContext.spark_session

# boas práticas p/ evitar inferência/merge pesada em parquet
spark.conf.set("spark.sql.parquet.mergeSchema", "false")

job = Job(glueContext)
job.init(args["JOB_NAME"], args)

ingestion_date = datetime.now(timezone.utc).strftime("%Y-%m-%d")
run_id = datetime.now(timezone.utc).strftime("%Y%m%dT%H%M%SZ")

ISO_Z = "yyyy-MM-dd'T'HH:mm:ssX"  # ex: 2025-07-05T02:00:00Z


def read_parquet(prefix: str):
    return spark.read.parquet(f"s3://{bucket}/{prefix}")


def require_cols(df, cols, name):
    missing = [c for c in cols if c not in df.columns]
    if missing:
        raise Exception(f"[ERRO] {name} sem colunas obrigatórias: {missing}. Colunas atuais: {df.columns}")


# --------------------
# Ler RAW
# --------------------
customers = read_parquet("raw/financeiro/customers/")
orders    = read_parquet("raw/vendas/orders/")
tickets   = read_parquet("raw/suporte/tickets/")

# --------------------
# Validar colunas mínimas
# --------------------
require_cols(customers, ["customer_id", "full_name"], "customers")
require_cols(orders, ["customer_id", "total"], "orders")
require_cols(tickets, ["customer_id", "created_at", "updated_at", "events_json"], "tickets")

# --------------------
# Normalizar tipos (join key como string)
# --------------------
customers = (
    customers.select("customer_id", "full_name")
             .withColumn("customer_id", F.col("customer_id").cast("string"))
)

orders = (
    orders.select("customer_id", "total")
          .withColumn("customer_id", F.col("customer_id").cast("string"))
          .withColumn("total_d", F.col("total").cast("double"))
)

tickets_sel = (
    tickets.select("customer_id", "created_at", "updated_at", "events_json")
           .withColumn("customer_id", F.col("customer_id").cast("string"))
)

# --------------------
# Agregado MySQL (orders)
# --------------------
orders_agg = (
    orders.groupBy("customer_id")
          .agg(
              F.count(F.lit(1)).alias("total_pedidos"),
              F.sum(F.coalesce(F.col("total_d"), F.lit(0.0))).alias("valor_total"),
          )
)

# --------------------
# Agregado Mongo (tickets)
# --------------------
events_schema = ArrayType(StructType([
    StructField("ts",   StringType(), True),
    StructField("type", StringType(), True),
    StructField("by",   StringType(), True),
    StructField("text", StringType(), True),
]))

tickets_base = (
    tickets_sel
    .withColumn("created_at_ts", F.to_timestamp(F.col("created_at"), ISO_Z))
    .withColumn("updated_at_ts", F.to_timestamp(F.col("updated_at"), ISO_Z))
    .withColumn("events_arr", F.from_json(F.col("events_json"), events_schema))
)

# max timestamp dentro de events.ts (se existir)
events_max = (
    tickets_base
    .withColumn("ev", F.explode_outer("events_arr"))
    .withColumn("event_ts", F.to_timestamp(F.col("ev.ts"), ISO_Z))
    .groupBy("customer_id")
    .agg(F.max("event_ts").alias("max_event_ts"))
)

tickets_agg = (
    tickets_base.groupBy("customer_id")
               .agg(
                   F.count(F.lit(1)).alias("qtde_chamados"),
                   F.max("created_at_ts").alias("max_created_at_ts"),
                   F.max("updated_at_ts").alias("max_updated_at_ts"),
               )
               .join(events_max, "customer_id", "left")
               .withColumn(
                   "ultima_interacao",
                   F.greatest(
                       F.col("max_updated_at_ts"),
                       F.col("max_event_ts"),
                       F.col("max_created_at_ts"),
                   )
               )
               .select("customer_id", "qtde_chamados", "ultima_interacao")
)

# --------------------
# Curated final (modelo pedido)
# --------------------
final_df = (
    customers.join(orders_agg, "customer_id", "left")
             .join(tickets_agg, "customer_id", "left")
             .select(
                 F.col("customer_id").alias("id_cliente"),
                 F.col("full_name").alias("nome"),
                 F.coalesce(F.col("total_pedidos"), F.lit(0)).alias("total_pedidos"),
                 F.coalesce(F.col("valor_total"), F.lit(0.0)).alias("valor_total"),
                 F.coalesce(F.col("qtde_chamados"), F.lit(0)).alias("qtde_chamados"),
                 F.col("ultima_interacao"),
             )
)

# --------------------
# Coluna de "origens" (rastreamento simples)
# --------------------
final_df = final_df.withColumn(
    "origens",
    F.concat_ws(
        ",",
        F.lit("postgres"),
        F.when(F.col("total_pedidos") > 0, F.lit("mysql")),
        F.when(F.col("qtde_chamados") > 0, F.lit("mongodb")),
    )
)

# --------------------
# Partição por ano/mês (camada curated)
# --------------------
ano = int(ingestion_date[0:4])
mes = int(ingestion_date[5:7])

final_df = (
    final_df
    .withColumn("ano", F.lit(ano))
    .withColumn("mes", F.lit(mes))
    .withColumn("ingestion_date", F.lit(ingestion_date))
    .withColumn("run_id", F.lit(run_id))
)

out_base = f"s3://{bucket}/curated/clientes_unificados/"
final_df.write.mode("overwrite").partitionBy("ano", "mes").parquet(out_base)

print(f"[OK] Curated gerado em: {out_base} (particionado por ano/mes)")
job.commit()
