resource "aws_iam_role" "log_role" {
  name               = var.log_role
  path               = "/service-role/"
  assume_role_policy = <<EOF
{
	"Version": "2012-10-17",
	"Statement": [{
		"Action": "sts:AssumeRole",
		"Principal": {
			"Service": "logs.${var.region}.amazonaws.com"
		},
		"Effect": "Allow",
		"Sid": ""
	}]
}
    
EOF

}

resource "aws_iam_policy" "stream_policy" {
  name        = "${var.header}_log_policy"
  description = "Kinesis stream permissions"

  policy = <<EOF
{
	"Version": "2012-10-17",
	"Statement": [{
			"Effect": "Allow",
			"Action": ["kinesis:PutRecord"],
			"Resource": "${var.kinesis_stream_arn}"
		},
		{
			"Effect": "Allow",
			"Action": ["iam:PassRole"],
			"Resource": "${aws_iam_role.log_role.arn}"
		}
	]
}
  
EOF

}

resource "aws_iam_policy_attachment" "log_role_attach" {
  name       = "log-role-attach"
  roles      = [aws_iam_role.log_role.name]
  policy_arn = aws_iam_policy.stream_policy.arn
}

resource "aws_cloudwatch_log_destination" "log_destination" {
  name       = var.log_destination_name
  role_arn   = aws_iam_role.log_role.arn
  target_arn = var.kinesis_stream_arn
}

