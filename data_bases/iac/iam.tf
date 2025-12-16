data "aws_iam_policy_document" "glue_assume_role" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["glue.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "glue_role" {
  name               = "lab-glue-role"
  assume_role_policy = data.aws_iam_policy_document.glue_assume_role.json
}

data "aws_iam_policy_document" "glue_policy" {
  statement {
    actions = [
      "s3:GetObject","s3:PutObject","s3:DeleteObject",
      "s3:ListBucket","s3:GetBucketLocation"
    ]
    resources = [
      "arn:aws:s3:::${var.bucket_name}",
      "arn:aws:s3:::${var.bucket_name}/*"
    ]
  }

  statement {
    actions = [
      "glue:GetDatabase","glue:GetDatabases",
      "glue:CreateTable","glue:UpdateTable","glue:GetTable","glue:GetTables",
      "glue:CreatePartition","glue:UpdatePartition","glue:GetPartition","glue:GetPartitions"
    ]
    resources = ["*"]
  }

  statement {
    actions = [
      "logs:CreateLogGroup","logs:CreateLogStream","logs:PutLogEvents"
    ]
    resources = ["*"]
  }
}

resource "aws_iam_role_policy" "glue_inline" {
  name   = "lab-glue-inline"
  role   = aws_iam_role.glue_role.id
  policy = data.aws_iam_policy_document.glue_policy.json
}
