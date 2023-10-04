variable "bucket_arn" {
  type = string
}

variable "aws_region" {
  type = string
}

variable "basename" {
  type = string
}

########## VPC ##########

variable "subnet_ids" {
  type = list
}

variable "vpc_id" {
  type = string
}

variable "cidr_block" {
  type = string
}

########## EKS ##########

variable "eks_node_volume_size" {
  type = number
}

variable "eks_node_volume_type" {
  type = string
}

variable "cluster_name" {
  type        = string
  description = "Name of the eks cluster"
}


variable "cluster_version" {
  type        = string
  description = "Version of k8s in EKS cluster"
}

variable "cluster_endpoint_private_access" {
  type        = bool
  description = "Indicates whether or not the Amazon EKS private API server endpoint is enabled"
}

variable "cluster_endpoint_public_access" {
  type        = bool
  description = "Indicates whether or not the Amazon EKS public API server endpoint is enabled"
}

variable "eks_node_ami_type" {
  type = string
}

variable "eks_node_disk_size" {
  type    = number
  description = "Disk size of default node"
}
variable "eks_node_instance_type" {
  type    = list(string)
}

variable "eks_node_instance_capacity_type" {
  type    = string
}


variable "eks_node_minimum_number" {
  type    = number
  description = "Minimum number node of eks cluster"
  default = 1
}


variable "eks_node_maximum_number" {
  type    = number
  description = "Minimum number node of eks cluster"
  default = 1
}


########## EC2 ##########

variable "bastion_name" {
  type = string
}

variable "bastion_ami_id" {
  type = string
}

variable "bastion_instance_type" {
  type = string
}

variable "bastion_key" {
  type = string
}

variable "bastion_subnet_id" {
  type = string
}