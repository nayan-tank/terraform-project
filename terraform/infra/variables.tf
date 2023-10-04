variable "aws_region" {
  type        = string
  default     = "us-east-2"
  description = "AWS region for terraform resources"
}

variable "bucket_arn" {
  type = string
}

########## VPC ##########
variable "vpc_cidr" {
  type = string
}

variable "basename" {
   description = "Prefix used for all resources names"
}

variable "private_subnet_list" {
   type = map
}

variable "public_subnet_list" {
   type = map
}

variable "route_cidr" {
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

variable "bastion_ami_id" {
  type = string
}

variable "bastion_instance_type" {
  type = string
}


variable "bastion_key" {
  type = string
}

variable "bastion_name" {
  type = string
}

########## ECR ##########

variable "ecr_repo_name" {
  type = string
}

variable "image_tag_mutability" {
  type = string
}

########## ACM ##################

variable "route53_domain_name" {
  type        = string
  description = "domain name dedicatedly for kubernetes environment. This hosted zone needs to be created first manually in AWS."
}