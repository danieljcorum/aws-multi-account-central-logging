variable "tags" {
  default = {
    "owner"   = ""
    "project" = "NA"
    "client"  = "NA"
  }
}
variable "bucketname" {
    default = ""
}
variable "cloudtrail_log_group_name" {
    default = ""
}
variable "aws_account_id" {
    default = ""
}
variable "aws_region" {
    default = ""
}
variable "trail_name" {
  default = ""
}

variable "cloudwatch_create" {
  default = ""
}
variable "cloudwatch_arn" {
  default = ""
}
variable "cloudwatch_id" {
  default = ""
}
