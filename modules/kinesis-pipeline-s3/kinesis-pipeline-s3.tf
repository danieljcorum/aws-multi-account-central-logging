resource "aws_s3_bucket" "log_bucket" {
  bucket = "${var.access_logs_bucket_name}"
  acl    = "log-delivery-write"
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
  bucket = "${aws_s3_bucket.log_bucket.id}"

  block_public_acls   = true
  block_public_policy = true
}

resource "aws_s3_bucket" "clb" {
  bucket = "${var.bucket_name}"
  acl    = "private"
  logging {
    target_bucket = "${aws_s3_bucket.log_bucket.id}"
    target_prefix = "log/"
  }
    versioning {
    enabled = true
  }

  lifecycle_rule {
    enabled = true

    transition {
      days = 60
      storage_class = "STANDARD_IA"
    }

    transition {
      days = 90
      storage_class = "GLACIER"
    }
    expiration {
      days = 365
    }
  }

  tags = {
    Name        = "${var.bucket_name}"
    Environment = "${var.env}"
    Project = "${var.project}"
    Owner = "${var.owner_group}"
    TPOC = "${var.technical_poc}"
  }
}

resource "aws_s3_bucket_public_access_block" "clb" {
  bucket = "${aws_s3_bucket.clb.id}"

  block_public_acls   = true
  block_public_policy = true
}
