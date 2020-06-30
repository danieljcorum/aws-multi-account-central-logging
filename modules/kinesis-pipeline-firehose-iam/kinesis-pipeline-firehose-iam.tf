resource "aws_iam_role" "firehose_role" {
  name = "${var.kinesis_pipeline_firehose_role_name}"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "Allowfirehoseservice",
      "Effect": "Allow",
      "Principal": {
        "Service": "firehose.amazonaws.com"
      },
      "Action": "sts:AssumeRole",
      "Condition": {
        "StringEquals": {
          "sts:ExternalId": "${var.aws_central_account_id}"
        }
      }

    }
  ]
}
EOF
}

resource "aws_iam_policy" "firehose_policy" {
  name        = "${var.kinesis_pipeline_firehose_policy_name}"
  description = "Firehose log processing permissions"

  policy = <<EOF
{
	"Version": "2012-10-17",
	"Statement": [
		{
			"Effect": "Allow",
			"Action": [
                "s3:AbortMultipartUpload",
                "s3:GetBucketLocation",
                "s3:GetObject",
                "s3:ListBucket",
                "s3:ListBucketMultipartUploads",
                "s3:PutObject"
			],
			"Resource": [
                "${var.dest_bucket_arn}",
                "${var.dest_bucket_arn}*"
            ]
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
      "kms:Decrypt"
      ],
      "Resource": "*"
    }
	]
}
  EOF
}

resource "aws_iam_policy_attachment" "firehose-attach" {
  name       = "firehose-attachment"
  roles      = ["${aws_iam_role.firehose_role.name}"]
  policy_arn = "${aws_iam_policy.firehose_policy.arn}"
}
