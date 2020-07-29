resource "aws_s3_bucket" "log_bucket" {
  bucket = var.access_logs_bucket_name
  acl    = "log-delivery-write"
  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }
  lifecycle_rule {
    id      = "central-logging-raw-vpcflow"
    enabled = true

    prefix = "vpcflowlogs/"

    tags = {
      "rule"      = "central-logging-raw-vpcflow"
      "autoclean" = "true"
    }

    transition {
      days          = 60
      storage_class = "STANDARD_IA" # or "ONEZONE_IA"
    }

    transition {
      days          = 90
      storage_class = "GLACIER"
    }

    expiration {
      days = 365
    }
  }
  lifecycle_rule {
    id      = "central-logging-raw-cloudtrail"
    enabled = true

    prefix = "cloudtrail/"

    tags = {
      "rule"      = "central-logging-raw-cloudtrail"
      "autoclean" = "true"
    }

    transition {
      days          = 60
      storage_class = "STANDARD_IA" # or "ONEZONE_IA"
    }

    transition {
      days          = 90
      storage_class = "GLACIER"
    }

    expiration {
      days = 365
    }
  }
  lifecycle_rule {
    id      = "central-logging-raw-ec2"
    enabled = true

    prefix = "ec2/"

    tags = {
      "rule"      = "central-logging-raw-ec2"
      "autoclean" = "true"
    }

    transition {
      days          = 60
      storage_class = "STANDARD_IA" # or "ONEZONE_IA"
    }

    transition {
      days          = 90
      storage_class = "GLACIER"
    }

    expiration {
      days = 365
    }
  }
}

resource "aws_s3_bucket_public_access_block" "log_bucket" {
  bucket = aws_s3_bucket.log_bucket.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket" "clb" {
  bucket = var.bucket_name
  acl    = "private"
  logging {
    target_bucket = aws_s3_bucket.log_bucket.id
    target_prefix = "log/"
  }
  versioning {
    enabled = true
  }

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }

  lifecycle_rule {
    enabled = true

    transition {
      days          = 60
      storage_class = "STANDARD_IA"
    }

    transition {
      days          = 90
      storage_class = "GLACIER"
    }
    expiration {
      days = 365
    }
  }

  tags = {
    Name        = var.bucket_name
    Environment = var.env
    Project     = var.project
    Owner       = var.owner_group
    TPOC        = var.technical_poc
  }
}

resource "aws_s3_bucket_public_access_block" "clb" {
  bucket = aws_s3_bucket.clb.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_policy" "log_bucket_policy" {
  bucket = aws_s3_bucket.log_bucket.id
  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "List Permissions for Account B Root",
            "Effect": "Allow",
            "Principal": {
                "AWS": "arn:aws-us-gov:iam::${var.acct_num}:root"
            },
            "Action": "s3:ListBucket",
            "Resource": "arn:aws-us-gov:s3:::${var.access_logs_bucket_name}"
        },
        {
            "Sid": "Sync Permissions for Account B IAM User",
            "Effect": "Allow",
            "Principal": {
                "AWS": "arn:aws-us-gov:iam::${var.acct_num}:root"
            },
            "Action": [
                "s3:GetObject",
                "s3:PutObject",
                "s3:PutObjectAcl",
                "s3:GetObjectAcl"
            ],
            "Resource": "arn:aws-us-gov:s3:::${var.access_logs_bucket_name}/*"
        },
        {
            "Sid": "Sync Permissions for Account B IAM User",
            "Effect": "Allow",
            "Principal": {
                "AWS": "arn:aws-us-gov:iam::${var.acct_num}:root"
            },
            "Action": [
                "s3:GetObject",
                "s3:PutObject",
                "s3:PutObjectAcl",
                "s3:GetObjectAcl"
            ],
            "Resource": "arn:aws-us-gov:s3:::${var.access_logs_bucket_name}/*"
        },
        {
            "Sid": "AWSCloudTrailAclCheck20150319",
            "Effect": "Allow",
            "Principal": {
                "Service": "cloudtrail.amazonaws.com"
            },
            "Action": "s3:GetBucketAcl",
            "Resource": "arn:aws-us-gov:s3:::${var.access_logs_bucket_name}"
        },
        {
            "Sid": "AWSCloudTrailWrite20150319",
            "Effect": "Allow",
            "Principal": {
                "Service": "cloudtrail.amazonaws.com"
            },
            "Action": "s3:PutObject",
            "Resource": "arn:aws-us-gov:s3:::${var.access_logs_bucket_name}/*",
            "Condition": {
                "StringEquals": {
                    "s3:x-amz-acl": "bucket-owner-full-control"
                }
            }
        }
    ]
}
EOF

}

resource "aws_s3_bucket_policy" "clb_policy" {
  bucket = aws_s3_bucket.clb.id
  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "List Permissions for Account B Root",
            "Effect": "Allow",
            "Principal": {
                "AWS": "arn:aws-us-gov:iam::${var.acct_num}:root"
            },
            "Action": "s3:ListBucket",
            "Resource": "arn:aws-us-gov:s3:::${var.bucket_name}"
        },
        {
            "Sid": "Sync Permissions for Account B IAM User",
            "Effect": "Allow",
            "Principal": {
                "AWS": "arn:aws-us-gov:iam::${var.acct_num}:root"
            },
            "Action": [
                "s3:GetObject",
                "s3:PutObject",
                "s3:PutObjectAcl",
                "s3:GetObjectAcl"
            ],
            "Resource": "arn:aws-us-gov:s3:::${var.bucket_name}/*"
        },
        {
            "Sid": "Sync Permissions for Account B IAM User",
            "Effect": "Allow",
            "Principal": {
                "AWS": "arn:aws-us-gov:iam::${var.acct_num}:root"
            },
            "Action": [
                "s3:GetObject",
                "s3:PutObject",
                "s3:PutObjectAcl",
                "s3:GetObjectAcl"
            ],
            "Resource": "arn:aws-us-gov:s3:::${var.bucket_name}/*"
        },
        {
            "Sid": "AWSCloudTrailAclCheck20150319",
            "Effect": "Allow",
            "Principal": {
                "Service": "cloudtrail.amazonaws.com"
            },
            "Action": "s3:GetBucketAcl",
            "Resource": "arn:aws-us-gov:s3:::${var.bucket_name}"
        },
        {
            "Sid": "AWSCloudTrailWrite20150319",
            "Effect": "Allow",
            "Principal": {
                "Service": "cloudtrail.amazonaws.com"
            },
            "Action": "s3:PutObject",
            "Resource": "arn:aws-us-gov:s3:::${var.bucket_name}/*",
            "Condition": {
                "StringEquals": {
                    "s3:x-amz-acl": "bucket-owner-full-control"
                }
            }
        }
    ]
}
EOF

}
