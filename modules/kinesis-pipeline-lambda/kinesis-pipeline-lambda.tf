resource "aws_lambda_function" "lambda" {
  function_name = var.kinesis_pipeline_lambda_name
  role          = var.kinesis_pipeline_lambda_role_arn
  handler       = "index.handler"
  filename      = "./modules/kinesis-pipeline-lambda/lambda.zip"

  source_code_hash = filebase64sha256("./modules/kinesis-pipeline-lambda/lambda.zip")
  runtime     = var.lambda_runtime
  timeout     = var.lambda_timeout_seconds
  memory_size = var.lambda_memory_size
}
