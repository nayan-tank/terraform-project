variable "basename" {
  description = "Prefix used for all resource names"
  type        = string
  default     = "dev"
}

######### VPC ############

variable "vpc_id" {
  type = string
}

variable "transition_to_ia_days" {
  type = number
}

variable "subnet_ids" {
  type = list
}

########## EFS #############

variable "efs_performance_mode" {
  description = "The performance mode of the EFS file system"
  type        = string
  default     = "generalPurpose"
}

variable "efs_throughput_mode" {
  description = "The throughput mode of the EFS file system"
  type        = string
  default     = "bursting"
}