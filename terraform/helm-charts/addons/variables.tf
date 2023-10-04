############## Infra State backend ##############

variable "infra_backend_bucket_name" {
  type        = string
}

variable "infra_state_file_path" {
  type        = string
}

variable "region" {
  type        = string
}

############### AWS CSI DRIVER ################

variable "image_repo" {
  default = "1234567890.dkr.ecr.ca-central-1.amazonaws.com/eks/aws-efs-csi-driver"
}

variable "create_sa_efs_csi" {
  default = true
}

variable "efs_csi_sa_name" {
  default = "efs-csi-controller-sa"
}

variable "node_sa_name" {
  default = "efs-csi-node-sa"
}


############### KARPENTER ###############

variable "karpenter_sa_name" {
  type        = string
}

variable "chart_url" {
  type        = string
}

variable "chart_version" {
  type        = string
}

############### AWS LB CONTROLLER ##################

variable "elb_sa_create" {
  default = true
}

variable "elb_sa_name" {
  default = "aws-load-balancer-controller"
}

############## EXTERNAL DNS #################

variable "ext_dns_sa_name" {
  default = "external-dns"
}

variable "txtOwnerId" {
  default = "externaldns"
}

variable "aws_zone_type" {
  default = "public"
}

variable "domain_filters" {
  type = string 
  # default = ["automation.dev.net", ]
  default = "automation.dev.net"
}