variable "region" {
  description = "name of region to deploy solution"
  default = "us-east-1"
}

variable "build_version" {
  description = "Build version number appended to the end of resources"
  default = ""
}

variable "shardcount" {
  default = "1"
}

variable "aws_central_account_id" {
  description = "aws account id for central logging account"
  default = ""
}

variable "env" {
  description = "Name of environment used for deployment"
  default = "prod"
}

variable "project" {
  description = "description of what we are building"
  default = "centralized-logging"
}

variable "owner_group" {
  description = "group responsible for deployment"
  default = ""
}

variable "header" {
  description = "group responsible for deployment"
  default = ""
}

variable "log_destination_name" {
  description = "name assigned to new log destination"
  default = ""
}


#Kinesis=firehose.tf variables
variable "dest_bucket_arn" {
  description = "destination bucket arn for kinesis firehose"
  default = ""
}

variable "s3_prefix" {
  description = "s3 prefix firehose will put logs to"
  default = ""
}
variable "kinesis_pipeline_lambda_arn" {
  description = "lambda function arn used by pipeline for log processing"
  default = ""
}

variable "firehose_role_arn" {
  description = "kinesis firehose role arn"
  default = ""
}

 variable "BufferSizeInMBs" {
   default = "3"
 }

variable "BufferIntervalInSeconds" {
   default = "60"
 }

 variable "processing_configuration_enabled" {
   default = "true"
 }
