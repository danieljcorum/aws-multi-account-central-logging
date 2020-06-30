variable "bu_acct_num" {
  description = "aws account id for bu account"
  type = list(string)
  default = []
}
variable "aws_cloudwatch_log_destination_arn" {
  description = "cloudwatch dest arn"
  type = list(string)
  default = []
}
variable "aws_cloudwatch_log_destination_name" {
  description = "cloudwatch dest name used for policy association"
  type = list(string)
  default = []
}

variable "log_destination_name_list" { default = [] }
variable "client_arns" { default = [] }
variable "dest_arns" { default = [] }
