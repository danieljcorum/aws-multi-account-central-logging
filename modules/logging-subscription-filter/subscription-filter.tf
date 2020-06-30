resource "aws_cloudwatch_log_subscription_filter" "central_logs_filter" {
  name            = "${var.central_logging_subscription_filter_name}"
  log_group_name  = "${var.log_group_name}"
  filter_pattern  = "${var.filter_pattern}"
  destination_arn = "${var.destination_arn}"
  distribution    = "Random"
}