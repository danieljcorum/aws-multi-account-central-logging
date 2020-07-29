variable "region" {
  default = "us-east-1"
}

variable "header" {
  description = "friendly name appended to the beginning of resources"
  default     = ""
}

variable "kinesis_stream_arn" {
  description = "ARN for kinesis stream log dest will send to"
  default     = ""
}

variable "log_destination_name" {
  description = "friendly log destination name"
  default     = ""
}

variable "log_role" {
  description = "Friendly name assigned to role granting perms to log destination"
  default     = ""
}

