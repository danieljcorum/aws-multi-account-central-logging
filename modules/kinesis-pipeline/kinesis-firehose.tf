resource "aws_kinesis_firehose_delivery_stream" "extended_s3_stream" {
  name        = "${var.header}-kinesis-stream"
  destination = "extended_s3"
  kinesis_source_configuration {
    kinesis_stream_arn = "${aws_kinesis_stream.isec_stream.arn}"
    role_arn           = "${var.firehose_role_arn}"
  }


  extended_s3_configuration {
    role_arn   = "${var.firehose_role_arn}"
    bucket_arn = "${var.dest_bucket_arn}"
    prefix             = "${var.s3_prefix}"
    buffer_size        = 50
    buffer_interval    = 60
    cloudwatch_logging_options {
      enabled         = "true"
      log_group_name  = "${aws_cloudwatch_log_group.mod.name}"
      log_stream_name = "${aws_cloudwatch_log_stream.mod.name}"
    }
    processing_configuration {
      enabled = "${var.processing_configuration_enabled}"

      processors {
        type = "Lambda"

        parameters {
          parameter_name  = "LambdaArn"
          parameter_value = "${var.kinesis_pipeline_lambda_arn}:$LATEST"
        }
        parameters {
          parameter_name  = "BufferSizeInMBs"
          parameter_value = "${var.BufferSizeInMBs}"
        }
        parameters {
          parameter_name = "BufferIntervalInSeconds"
          parameter_value = "${var.BufferIntervalInSeconds}"
        }
      }
    }
  }
}
