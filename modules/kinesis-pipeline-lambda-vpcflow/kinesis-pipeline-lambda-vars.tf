
variable "kinesis_pipeline_lambda_name" {
    description = "lambda function name used by kinesis firehose for log transformation"
    default = "kin-hs-cw-log-processor"
}

variable "kinesis_pipeline_lambda_role_arn" {
    description = "lambda function role name for role granting necessary perms"
    default = ""
}

variable "lambda_runtime" {
    description = "lambda code/version for lambda function"
    default = "nodejs8.10"
}
/*
These settings allow you to control the code execution performance 
and costs for your Lambda function. Changing your resource settings (by selecting memory) 
or changing the timeout may impact your function cost. Learn more about how Lambda pricing works.
*/
variable "lambda_timeout_seconds" {
    description = "sets the timeout interval for lambda function in seconds"
    default = "30"
}

variable "lambda_memory_size" {
    description = "sets the memory allocated to the lambda function"
    default = "128"
}


