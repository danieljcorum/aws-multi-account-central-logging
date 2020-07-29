resource "aws_flow_log" "vpc" {
  log_group_name = var.log_group_name
  iam_role_arn = var.aws_iam_role_log_arn
  vpc_id       = var.vpc_id
  traffic_type = var.traffic_type
}
