
resource "aws_cloudwatch_log_group" "vpc_flow_log" {
  name              = "${var.vpc_id}-vpc_flow_log"
  retention_in_days = "${var.retention_in_days}"
}

resource "aws_flow_log" "vpc" {
  log_group_name = "${aws_cloudwatch_log_group.vpc_flow_log.name}"
  iam_role_arn   = "${var.aws_iam_role_log_arn}"
  vpc_id         = "${var.vpc_id}"
  traffic_type   = "${var.traffic_type}"
}

