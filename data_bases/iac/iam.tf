# Trust policy (assume role) para o Glue
data "aws_iam_policy_document" "glue_assume_role" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["glue.amazonaws.com"]
    }
  }
}

# Role do Glue
resource "aws_iam_role" "glue_role" {
  name               = "lab-glue-role"
  assume_role_policy = data.aws_iam_policy_document.glue_assume_role.json
}


data "aws_iam_policy" "lab_global_policy" {
  name = "lab-ingestor-s3-raw-curated"
}

# Anexa a policy global na role do Glue
resource "aws_iam_role_policy_attachment" "glue_global_policy" {
  role       = aws_iam_role.glue_role.name
  policy_arn = data.aws_iam_policy.lab_global_policy.arn
}