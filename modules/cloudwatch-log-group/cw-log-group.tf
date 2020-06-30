resource "aws_cloudwatch_log_group" "lg" {
  name = "${var.name}"
}

variable "name" {
  default = ""
}


output "cloudwatch_arn" {
  value = "${aws_cloudwatch_log_group.lg.arn}"
}

output "cloudwatch_id" {
  value = "${aws_cloudwatch_log_group.lg.id}"
}
