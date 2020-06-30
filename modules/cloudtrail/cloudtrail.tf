
#Enables Cloudtrail, creates bucket to store cloudtrail events along with policies required.
resource "aws_s3_bucket" "log_bucket" {
  bucket = "${var.bucketname}-accesslogs"
  acl    = "log-delivery-write"
}

resource "aws_s3_bucket" "bulogs" {
  bucket = "${var.bucketname}"
  acl    = "private"
logging {
    target_bucket = "${aws_s3_bucket.log_bucket.id}"
    target_prefix = "logs/"
  }
  lifecycle_rule {
    enabled = true

    transition {
      days = 30
      storage_class = "STANDARD_IA"
    }

    transition {
      days = 60
      storage_class = "GLACIER"
    }
  }
}

resource "aws_s3_bucket_policy" "b" {
  bucket = "${aws_s3_bucket.bulogs.id}"

  policy = <<POLICY
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "AWSCloudTrailAclCheck20150319",
            "Effect": "Allow",
            "Principal": {"Service": "cloudtrail.amazonaws.com"},
            "Action": "s3:GetBucketAcl",
            "Resource": "${aws_s3_bucket.bulogs.arn}"
        },
        {
            "Sid": "AWSCloudTrailWrite20150319",
            "Effect": "Allow",
            "Principal": {"Service": "cloudtrail.amazonaws.com"},
            "Action": "s3:PutObject",
            "Resource": "${aws_s3_bucket.bulogs.arn}/${var.trail_name}/*",
            "Condition": {"StringEquals": {"s3:x-amz-acl": "bucket-owner-full-control"}}
        }
    ]
}
POLICY
}

# -----------------------------------------------------------
# setup permissions to allow cloudtrail to write to cloudwatch
# -----------------------------------------------------------
resource "aws_iam_role" "cloudtrail_to_cloudwatch" {
  name = "cloudtrail-to-cloudwatch"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "cloudtrail.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_policy" "cloudtrail_to_cloudwatch" {
  name = "cloudtrail-to-cloudwatch"
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "AWSCloudTrailCreateLogStream",
      "Effect": "Allow",
      "Action": ["logs:CreateLogStream"],
      "Resource": [
        "arn:aws:logs:${var.aws_region}:${var.aws_account_id}:log-group:${var.cloudwatch_create == "true" ? aws_cloudwatch_log_group.cloudtrail.id : var.cloudwatch_id}:log-stream:*"
      ]
    },
    {
      "Sid": "AWSCloudTrailPutLogEvents",
      "Effect": "Allow",
      "Action": ["logs:PutLogEvents"],
      "Resource": [
        "arn:aws:logs:${var.aws_region}:${var.aws_account_id}:log-group:${var.cloudwatch_create == "true" ? aws_cloudwatch_log_group.cloudtrail.id : var.cloudwatch_id}:log-stream:*"
      ]
    }
  ]
}
EOF
}

# -----------------------------------------------------------
# attach policy to role
# -----------------------------------------------------------
resource "aws_iam_policy_attachment" "cloudtrail-attach" {
  name       = "cloudtrail-attachment"
  roles      = ["${aws_iam_role.cloudtrail_to_cloudwatch.name}"]
  policy_arn = "${aws_iam_policy.cloudtrail_to_cloudwatch.arn}"
}

# -----------------------------------------------------------
# setup cloudwatch logs to receive cloudtrail events
# -----------------------------------------------------------

resource "aws_cloudwatch_log_group" "cloudtrail" {
  name = "${var.cloudtrail_log_group_name}"
  retention_in_days = 30
  tags              = "${merge(map("Name","Cloudtrail"), var.tags)}"
}

# -----------------------------------------------------------
# turn cloudtrail on for this region
# -----------------------------------------------------------

resource "aws_cloudtrail" "butrail" {
  name                          = "${var.trail_name}"
  s3_bucket_name                = "${aws_s3_bucket.bulogs.id}"
  s3_key_prefix                 = "${var.trail_name}"
  include_global_service_events = true
  enable_logging                = true
  is_multi_region_trail         = false
  enable_log_file_validation    = true
  cloud_watch_logs_group_arn    = "${var.cloudwatch_create == "true" ? aws_cloudwatch_log_group.cloudtrail.arn : var.cloudwatch_arn}"
  cloud_watch_logs_role_arn     = "${aws_iam_role.cloudtrail_to_cloudwatch.arn}"

  event_selector {
    read_write_type           = "All"
    include_management_events = true
  }

  tags = "${merge(map("Name","Example account audit"), var.tags)}"
  depends_on = ["aws_s3_bucket.bulogs"]
}


output "log_group_name" {
  value = "${var.cloudtrail_log_group_name}"
}
