terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.19"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

resource "aws_glue_catalog_database" "metadata" {
  name        = "metadata-database"
  description = "Data Catalog para RAW/CURATED do lab"
}
