#log group subscription filter data
variable "destination_arn" {
  description = "arn of logs destination"
  default     = ""
}

variable "central_logging_subscription_filter_name" {
  description = "friendly name assigned to subscription filter"
  default     = ""
}

variable "log_group_name" {
  description = "name of loggroup to forward logs from"
  default     = ""
}

variable "filter_pattern" {
  default = ""
}

