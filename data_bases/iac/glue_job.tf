resource "aws_s3_object" "unified_job_script" {
  bucket = var.bucket_name
  key    = "glue/scripts/unified_job.py"
  source = "${path.module}/scripts/unified_job.py"
  etag   = filemd5("${path.module}/scripts/unified_job.py")
}

resource "aws_glue_job" "unified_job" {
  name     = "lab-unified-job"
  role_arn = aws_iam_role.glue_role.arn

  # Ajuste se necessário (ex: "4.0" ou o que você estiver usando no console)
  glue_version = "4.0"

  command {
    name            = "glueetl"
    script_location = "s3://${var.bucket_name}/${aws_s3_object.unified_job_script.key}"
    python_version  = "3"
  }

  default_arguments = {
    "--job-language"                     = "python"
    "--enable-metrics"                   = "true"
    "--enable-continuous-cloudwatch-log" = "true"
    "--enable-spark-ui"                  = "true"
    "--spark-event-logs-path"            = "s3://${var.bucket_name}/sparkHistoryLogs/"
    "--S3_BUCKET"                        = var.bucket_name
  }
}
