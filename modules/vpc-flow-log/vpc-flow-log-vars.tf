
variable "traffic_type" {
  default = "ALL"
}
variable "vpc_id" {
  default = ""
}

variable "aws_iam_role_log_arn" {
    default = ""
}

variable "retention_in_days" {
  default = "7"
}
