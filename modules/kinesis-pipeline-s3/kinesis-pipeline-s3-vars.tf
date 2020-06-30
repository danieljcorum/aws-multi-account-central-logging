
variable "bucket_name" {
  description = "Bucket name for the centralized logging bucket"
  default = ""
}

variable "build_version" {
  description = "build version appended to resource names"
  default = ""
}

variable "access_logs_bucket_name" {
  description = "Bucket name for the centralized logging bucket"
  default = ""
}
variable "logstash_instance_profile_role_arn" {
  default = ""
}

#Tags/Naming
variable "env" {
  description = "Name of environment used for deployment"
  default = ""
}

variable "project" {
  description = "description of what we are building"
  default = ""
}

variable "owner_group" {
  description = "group responsible for deployment"
  default = ""
}

variable "header" {
  description = "group responsible for deployment"
  default = ""
}

variable "technical_poc" {
  description = "preferrably group email"
  default = ""
}
