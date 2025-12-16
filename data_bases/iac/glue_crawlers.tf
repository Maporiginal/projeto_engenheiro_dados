resource "aws_glue_crawler" "raw_crawler" {
  name          = "lab-raw-crawler"
  role          = aws_iam_role.glue_role.arn
  database_name = aws_glue_catalog_database.metadata.name

  s3_target { path = "s3://${var.bucket_name}/raw/financeiro/customers/" }
  s3_target { path = "s3://${var.bucket_name}/raw/financeiro/ledger/" }
  s3_target { path = "s3://${var.bucket_name}/raw/vendas/orders/" }
  s3_target { path = "s3://${var.bucket_name}/raw/vendas/order_items/" }
  s3_target { path = "s3://${var.bucket_name}/raw/suporte/tickets/" }

  recrawl_policy {
    recrawl_behavior = "CRAWL_EVERYTHING"
  }

  schema_change_policy {
    update_behavior = "UPDATE_IN_DATABASE"
    delete_behavior = "DEPRECATE_IN_DATABASE"
  }
}

resource "aws_glue_crawler" "curated_crawler" {
  name          = "lab-curated-crawler"
  role          = aws_iam_role.glue_role.arn
  database_name = aws_glue_catalog_database.metadata.name

  s3_target { path = "s3://${var.bucket_name}/curated/clientes_unificados/" }

  recrawl_policy {
    recrawl_behavior = "CRAWL_EVERYTHING"
  }

  schema_change_policy {
    update_behavior = "UPDATE_IN_DATABASE"
    delete_behavior = "DEPRECATE_IN_DATABASE"
  }
}
