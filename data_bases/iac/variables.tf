variable "aws_region" {
  type    = string
  default = "us-east-1"
}

variable "bucket_name" {
  type    = string
  default = "maporiginal-data-lake-dev-us-east-1-20251215"
}

variable "glue_database_name" {
  type    = string
  default = "metadata-database-raw-curated"
}
