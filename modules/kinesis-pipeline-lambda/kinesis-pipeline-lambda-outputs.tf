
output "kinesis_pipeline_lambda_arn" {
  value = "${aws_lambda_function.lambda.arn}"
}
