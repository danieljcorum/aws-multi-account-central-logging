variable "region" {
  default = "us-east-1"
}

variable "logging_account_role_arn" {
  description = "IAM Role of the logging account with permission to s3, kinesis, cloudwatch"
}

variable "client_account_role_arn" {
  description = "IAM Role of the client account with permission to cloudwatch and other services you would like to collect logs from"
}

provider "aws" {
  alias = "logging"
  region  = var.region
  assume_role {
    role_arn     = var.logging_account_role_arn
  }
}

provider "aws" {
  alias = "client"
  region  = var.region
  assume_role {
    role_arn     = var.client_account_role_arn
  }
}

########## Lambda to format logs from cloudtrail and cloudwatch agent and role to allow
module "lambda-iam" {
  source = "../modules/kinesis-pipeline-lambda-iam"
  providers = {
    "aws" = "aws.logging"
  }
  lambda_logs_policy_name = "client-accountNumber-kinesis-pipeline-lambda-policy"
  lambda_logs_role_name = "client-accountNumber-kinesis-pipeline-lambda-role"
}

module "lambda-logs" {
  source = "../modules/kinesis-pipeline-lambda"
  providers = {
    "aws" = "aws.logging"
  }
  kinesis_pipeline_lambda_name = "client-accountNumber-kin-hs-cw-log-processor"
  kinesis_pipeline_lambda_role_arn= module.lambda-iam.lambda_log_role_arn
  lambda_timeout_seconds = "60"
  lambda_runtime = "nodejs12.x"
}

########## Lambda to format logs from vpcflow logs agent and role to allow
module "lambda-logs-vpcflow" {
  source = "../modules/kinesis-pipeline-lambda-vpcflow"
  providers = {
    "aws" = "aws.logging"
  }
  kinesis_pipeline_lambda_name = "client-accountNumber-kin-vpcflow-pipeline"
  kinesis_pipeline_lambda_role_arn= module.lambda-iam.lambda_log_role_arn
  lambda_timeout_seconds = "60"
  lambda_memory_size = "512"
  lambda_runtime = "nodejs12.x"
}

########## IAM Role For Kinesis To S3 operations
module "kinesis-pipeline-firehose-iam" {
  source = "../modules/kinesis-pipeline-firehose-iam"
  providers = {
    "aws" = "aws.logging"
  }
  aws_central_account_id = "AccountNumberOfLoggingAccount"
  dest_bucket_arn = "DestinationS3BucketToStoreLogs"
  kinesis_pipeline_firehose_role_name = "IAMRoleName"
  kinesis_pipeline_firehose_policy_name = "IAMPolicyName"
}

########## S3 Buckets For Log Storage
module "S3-client" {
  source = "../modules/kinesis-pipeline-s3"
  providers = {
    "aws" = "aws.logging"
  }
  technical_poc = "BucketOwnerName"
  owner_group = "BucketOwnerGroup"
  project = "ProjectName"
  env = "EnvironmentName"
  bucket_name = "BucketName"
  access_logs_bucket_name = "S3BucketName"
  logstash_instance_profile_role_arn = var.client_account_role_arn
}

########## EC2/Cloudwatch Agent Logs Kinesis Stream
module "client-kinesis-pipeline-ec2" {
  source = "../modules/kinesis-pipeline"
  providers = {
    "aws" = "aws.logging"
  }
  dest_bucket_arn = module.S3-client.dest_bucket_arn
  s3_prefix = "ec2/"
  kinesis_pipeline_lambda_arn = module.lambda-logs.kinesis_pipeline_lambda_arn
  firehose_role_arn = module.kinesis-pipeline-firehose-iam.firehose_role_arn
  header = "GenericName"
  project = "ProjectName"
  env = "ProjectEnvironment"
  build_version = "VersionNumber"
  shardcount = "1"
  BufferIntervalInSeconds = "60"
  BufferSizeInMBs = "3"
}

########## EC2/Cloudwatch Agent Log Destination and IAM Role assigned
module "kinesis-pipeline-log-destination-client-ec2" {
  source = "../modules/kinesis-pipeline-log-destination"
  providers = {
    "aws" = "aws.logging"
  }
  log_role = "IAMRoleName"
  region = var.region
  header = "IamPolicyName"
  kinesis_stream_arn = module.client-kinesis-pipeline-ec2.dest_kinesis_arn
  log_destination_name = "LogDestinationName"
}

########## VPCFlow Logs Kinesis Stream
module "kinesis-pipeline-client-vpcflowlogs" {
  source = "../modules/kinesis-pipeline"
  providers = {
    "aws" = "aws.logging"
  }
  dest_bucket_arn = module.S3-client.dest_bucket_arn
  s3_prefix = "vpcflowlogs/"
  kinesis_pipeline_lambda_arn = module.lambda-logs-vpcflow.kinesis_pipeline_lambda_arn
  firehose_role_arn = module.kinesis-pipeline-firehose-iam.firehose_role_arn
  header = "GenericName"
  project = "ProjectName"
  env = "ProjectEnvironment"
  build_version = ""
  shardcount = "4"
  BufferIntervalInSeconds = "60"
  BufferSizeInMBs = "3"
  processing_configuration_enabled = "true"
}

########## VPCFlow Log Destination and IAM Role assigned
module "kinesis-pipeline-log-destination-client-vpcflowlogs" {
  source = "../modules/kinesis-pipeline-log-destination"
  providers = {
    "aws" = "aws.logging"
  }
  log_role = "IAMRoleName"
  region = var.region
  header = "IamPolicyName"
  kinesis_stream_arn = module.kinesis-pipeline-client-vpcflowlogs.dest_kinesis_arn
  log_destination_name = "LogDestinationName"
}

########## Cloudtrail Logs Kinesis Stream
module "kinesis-pipeline-client-cloudtrail" {
  source = "../modules/kinesis-pipeline"
  providers = {
    "aws" = "aws.logging"
  }
  dest_bucket_arn = module.S3-client.dest_bucket_arn
  s3_prefix = "cloudtrail/"
  kinesis_pipeline_lambda_arn = module.lambda-logs.kinesis_pipeline_lambda_arn
  firehose_role_arn = module.kinesis-pipeline-firehose-iam.firehose_role_arn
  header = "GenericName"
  project = "ProjectName"
  env = "ProjectEnvironment"
  build_version = ""
  shardcount = "4"
  BufferIntervalInSeconds = "60"
  BufferSizeInMBs = "3"
  processing_configuration_enabled = "true"
}

########## Cloudtrail Log Destination and IAM Role assigned
module "kinesis-pipeline-log-destination-client-ctrail" {
  source = "../modules/kinesis-pipeline-log-destination"
  providers = {
    "aws" = "aws.logging"
  }
  log_role = "IAMRoleName"
  region = var.region
  header = "IamPolicyName"
  kinesis_stream_arn = module.kinesis-pipeline-client-cloudtrail.dest_kinesis_arn
  log_destination_name = "LogDestinationName"
}

########## Log Destination Policy applied to above log group destinations
module "cloudwatch-log-destination-policy-client" {
  source = "../modules/cloudwatch-log-destination-policy"
  providers = {
    "aws" = "aws.logging"
  }
  bu_acct_num = ["ClientAccountNumber"]
  client_arns = ["ClientRootArn"]
  aws_cloudwatch_log_destination_arn = ["${module.kinesis-pipeline-log-destination-client-vpcflowlogs.aws_cloudwatch_log_destination_arn},${module.kinesis-pipeline-log-destination-client-ec2.aws_cloudwatch_log_destination_arn},${module.kinesis-pipeline-log-destination-client-ctrail.aws_cloudwatch_log_destination_arn}"]

  aws_cloudwatch_log_destination_name = ["${module.kinesis-pipeline-log-destination-client-vpcflowlogs.aws_cloudwatch_log_destination_name},${module.kinesis-pipeline-log-destination-client-ec2.aws_cloudwatch_log_destination_name},${module.kinesis-pipeline-log-destination-client-ctrail.aws_cloudwatch_log_destination_name}"]

  log_destination_name_list = ["${module.kinesis-pipeline-log-destination-client-vpcflowlogs.aws_cloudwatch_log_destination_name}","${module.kinesis-pipeline-log-destination-client-ec2.aws_cloudwatch_log_destination_name}","${module.kinesis-pipeline-log-destination-client-ctrail.aws_cloudwatch_log_destination_name}"]

  dest_arns = ["${module.kinesis-pipeline-log-destination-client-vpcflowlogs.aws_cloudwatch_log_destination_arn}","${module.kinesis-pipeline-log-destination-client-ec2.aws_cloudwatch_log_destination_arn}","${module.kinesis-pipeline-log-destination-client-ctrail.aws_cloudwatch_log_destination_arn}"]
}

########## Client Cloudwatch Log Groups
module "client-ec2-lg" {
  source = "../modules/cloudwatch-log-group"
  providers = {
    "aws" = "aws.client"
  }
  name = "client/ec2"
}

module "client-ctrail-lg" {
  source = "../modules/cloudwatch-log-group"
  providers = {
    "aws" = "aws.client"
  }
  name = "client/cloudtrail"
}

module "client-vpcflow-lg" {
  source = "../modules/cloudwatch-log-group"
  providers = {
    "aws" = "aws.client"
  }
  name = "client/vpcflow"
}

########## Client Subscription Filters for Log Groups
module "client-bu-log-subscription-filter-ec2" {
  source = "../modules/logging-subscription-filter"
    providers = {
    "aws" = "aws.client"
  }
  destination_arn = module.kinesis-pipeline-log-destination-client-ec2.aws_cloudwatch_log_destination_arn
  log_group_name = module.client-ec2-lg.name
  central_logging_subscription_filter_name = "NameForTheFilter"
}

module "client-bu-log-subscription-filter-ctrail" {
  source = "../modules/logging-subscription-filter"
    providers = {
    "aws" = "aws.client"
  }
  destination_arn = module.kinesis-pipeline-log-destination-client-ctrail.aws_cloudwatch_log_destination_arn
  log_group_name = module.client-ctrail-lg.name
  central_logging_subscription_filter_name = "NameForTheFilter"
}

module "client-bu-log-subscription-filter-vpcflow" {
  source = "../modules/logging-subscription-filter"
    providers = {
    "aws" = "aws.client"
  }
  destination_arn = module.kinesis-pipeline-log-destination-client-vpcflowlogs.aws_cloudwatch_log_destination_arn
  log_group_name = module.client-vpcflow-lg.name
  central_logging_subscription_filter_name = "NameForTheFilter"
}

########## Enable Cloudtrail on client
module "cloudtrail" {
  source = "../modules/cloudtrail"
    providers = {
    "aws" = "aws.client"
  }
  aws_region = var.region
  aws_account_id = "ClientAccountNumber"
  cloudwatch_create = "false"
  cloudwatch_arn = module.client-cloudtrail-lg.cloudwatch_arn
  cloudwatch_id = module.client-cloudtrail-lg.cloudwatch_id
  bucketname = "ClientS3BucketName"
}

########## Create VPC Flow IAM role and policy
module "vpcflow-client-iam" {
  source = "../modules/vpc-flow-log-iam"
}

########## Enable VPC Flow logs to the above log group for each env vpc
module "vpcflow-client-prod" {
  source = "../modules/vpc-flow-log"
  providers = {
    "aws" = "aws.client"
  }
traffic_type = "ALL"
vpc_id = "ProdVPC"
aws_iam_role_log_arn = module.vpcflow-client-iam.role_arn
}

module "vpcflow-client-qa" {
  source = "../modules/vpc-flow-log"
  providers = {
    "aws" = "aws.client"
  }
traffic_type = "ALL"
vpc_id = "QAVPC"
aws_iam_role_log_arn = module.vpcflow-client-iam.role_arn
}

module "vpcflow-client-dev" {
  source = "../modules/vpc-flow-log"
  providers = {
    "aws" = "aws.client"
  }
traffic_type = "ALL"
vpc_id = "DevVPC"
aws_iam_role_log_arn = module.vpcflow-client-iam.role_arn
}
