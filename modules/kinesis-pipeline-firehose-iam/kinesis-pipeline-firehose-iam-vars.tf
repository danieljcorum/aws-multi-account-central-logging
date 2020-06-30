
variable "aws_central_account_id" {
    description = "account id for logging account where pipeline will be created"
    default = ""
}

variable "dest_bucket_arn" {
    description = "logging account data lake log bucket"
    default = ""
}

variable "kinesis_pipeline_firehose_role_name" {
    description = "name assigned to role granting firehose perms"
    default = ""

}

variable "kinesis_pipeline_firehose_policy_name" {
    description = "name assigned to policy granting firehose perms"
    default = ""
}
