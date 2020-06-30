output "aws_cloudwatch_log_destination_arn" {
  value = "${aws_cloudwatch_log_destination.log_destination.arn}"
}

output "aws_cloudwatch_log_destination_name" {
  value = "${var.log_destination_name}"
}