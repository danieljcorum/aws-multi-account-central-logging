output "lambda_log_role_arn" {
  value = "${aws_iam_role.lambda_logs.arn}"
}