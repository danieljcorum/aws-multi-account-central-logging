resource "aws_iam_policy" "policy" {
  name        = var.lambda_logs_policy_name
  description = "firehoseCloudWatchDataProcessing permissions"

  policy = <<EOF
{
	"Version": "2012-10-17",
	"Statement": [
		{
			"Effect": "Allow",
			"Action": [
				"logs:CreateLogGroup",
				"logs:CreateLogStream",
				"logs:PutLogEvents"
			],
			"Resource": "arn:aws:logs:*:*:*"

		},
		{
			"Effect": "Allow",
			"Action": [
			"lambda:InvokeFunction",
			"lambda:GetFunctionConfiguration",
			"logs:PutLogEvents",
			"kinesis:DescribeStream",
			"kinesis:GetShardIterator",
			"kinesis:GetRecords",
			"kinesis:PutRecords",
			"kms:Decrypt"
      ],
      		"Resource": "*"
    }
	]
}
  
EOF

}

resource "aws_iam_role" "lambda_logs" {
  name = var.lambda_logs_role_name

  assume_role_policy = <<EOF
{
	"Version": "2012-10-17",
	"Statement": [{
		"Action": "sts:AssumeRole",
		"Principal": {
			"Service": "lambda.amazonaws.com"
		},
		"Effect": "Allow",
		"Sid": ""
	}]
}
    
EOF

}

resource "aws_iam_policy_attachment" "attach" {
  name       = "attachment"
  roles      = [aws_iam_role.lambda_logs.name]
  policy_arn = aws_iam_policy.policy.arn
}

