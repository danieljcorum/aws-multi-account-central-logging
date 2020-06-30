variable "vpc_flow_enabled" {
  default = true
}

data "aws_iam_policy_document" "log_assume" {

  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["vpc-flow-logs.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "log" {
  statement {
    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents",
      "logs:DescribeLogGroups",
      "logs:DescribeLogStreams",
    ]

    resources = [
      "*",
    ]
  }
}

resource "aws_iam_role_policy" "log" {
  name   = "vpcflowlog-policy"
  role   = "${aws_iam_role.log.id}"
  policy = "${data.aws_iam_policy_document.log.json}"
}

resource "aws_iam_role" "log" {
  name               = "vpcflowlog-role"
  assume_role_policy = "${data.aws_iam_policy_document.log_assume.json}"
}

output "role_arn" {
  value = "${aws_iam_role.log.arn}"
}