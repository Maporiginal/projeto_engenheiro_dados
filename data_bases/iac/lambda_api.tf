# LAMBDA ZIP 
data "archive_file" "clientes_api_zip" {
  type        = "zip"
  source_file = "${path.module}/lambda/clientes_api.py"
  output_path = "${path.module}/lambda/clientes_api.zip"
}

# IAM ROLE (Lambda) 
resource "aws_iam_role" "lambda_clientes_role" {
  name = "lab-lambda-clientes-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = { Service = "lambda.amazonaws.com" }
      Action    = "sts:AssumeRole"
    }]
  })
}

# Logs no CloudWatch (bom pra debug)
resource "aws_iam_role_policy_attachment" "lambda_basic_logs" {
  role       = aws_iam_role.lambda_clientes_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

# FULL ADMIN (temporário, só pra fazer funcionar rápido)
resource "aws_iam_role_policy_attachment" "lambda_admin" {
  role       = aws_iam_role.lambda_clientes_role.name
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
}



# ANEXA POLICY GLOBAL NA ROLE DO LAMBDA 
# (esse data precisa existir UMA vez no diretório. Se já existe em outro .tf, remova daqui.)

resource "aws_iam_role_policy_attachment" "lambda_global_policy" {
  role       = aws_iam_role.lambda_clientes_role.name
  policy_arn = data.aws_iam_policy.lab_global_policy.arn
}

# LAMBDA FUNCTION
resource "aws_lambda_function" "clientes_api" {
  function_name = "lab-clientes-api"
  role          = aws_iam_role.lambda_clientes_role.arn
  handler       = "clientes_api.lambda_handler"
  runtime       = "python3.11"
  timeout       = 30
  memory_size   = 256

  filename         = data.archive_file.clientes_api_zip.output_path
  source_code_hash = data.archive_file.clientes_api_zip.output_base64sha256

  environment {
    variables = {
      ATHENA_DATABASE  = aws_glue_catalog_database.metadata.name
      ATHENA_TABLE     = "clientes_unificados"
      ATHENA_OUTPUT    = "s3://${var.bucket_name}/athena-results/"
      ATHENA_WORKGROUP = "primary"
    }
  }
}

# API GATEWAY HTTP API
resource "aws_apigatewayv2_api" "clientes_http_api" {
  name          = "lab-clientes-http-api"
  protocol_type = "HTTP"
}

resource "aws_apigatewayv2_integration" "clientes_integration" {
  api_id                 = aws_apigatewayv2_api.clientes_http_api.id
  integration_type       = "AWS_PROXY"
  integration_uri        = aws_lambda_function.clientes_api.invoke_arn
  payload_format_version = "2.0"
}

resource "aws_apigatewayv2_route" "clientes_route" {
  api_id    = aws_apigatewayv2_api.clientes_http_api.id
  route_key = "GET /clientes"
  target    = "integrations/${aws_apigatewayv2_integration.clientes_integration.id}"
}

resource "aws_apigatewayv2_stage" "default" {
  api_id      = aws_apigatewayv2_api.clientes_http_api.id
  name        = "$default"
  auto_deploy = true
}

resource "aws_lambda_permission" "allow_apigw" {
  statement_id  = "AllowInvokeFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.clientes_api.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.clientes_http_api.execution_arn}/*/*"
}

output "clientes_api_base_url" {
  value = aws_apigatewayv2_stage.default.invoke_url
}
