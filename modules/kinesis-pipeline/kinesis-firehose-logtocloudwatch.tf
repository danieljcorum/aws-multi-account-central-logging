#This will create the cloudwatch log group/stream
#used to capture firehose errors

resource "aws_cloudwatch_log_group" "mod" {
  name  = "${var.header}-kf-errors-${var.build_version}"

  tags = {
    Environment = "${var.env}"
    Project = "${var.project}"
  }
}

resource "aws_cloudwatch_log_stream" "mod" {
  name  = "${var.header}-kf-errors"
  log_group_name = "${aws_cloudwatch_log_group.mod.name}"
}
