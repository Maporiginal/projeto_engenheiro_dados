terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.19"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

resource "aws_glue_catalog_database" "metadata" {
  name        = var.glue_database_name
  description = "Data Catalog para RAW/CURATED do lab"
}
