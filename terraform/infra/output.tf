################################################################################
# Cluster
################################################################################

output "aws_region" {
  description = "region"
  value       = var.aws_region
}

output "cluster_endpoint" {
  description = "Endpoint for your Kubernetes API server"
  value       = module.eks.cluster_endpoint
}


output "cluster_name" {
  description = "The name of the EKS cluster"
  value       = module.eks.cluster_name
}

output "cluster_iam_role_name" {
  description = "IAM role name of the EKS cluster"
  value       = module.eks.cluster_iam_role_name
}

####### IRSA ###########
output "irsa_iam_role_arn" {
  description = "ARN of IRSA IAM role"
  value       = module.eks.irsa_iam_role_arn
}

output "irsa_iam_role_name" {
  description = "ARN of IRSA IAM role"
  value       = module.eks.irsa_iam_role_name
}

####### EFS ############
output "efs_id" {
  description = "ID of EFS"
  value       = module.efs.efs_id
}

####### BAstion Host
output "bastion_host_id" {
  description = "The id of the bastion ec2"
  value       = module.eks.bastion_host_id
}

output "bastion_host_ip" {
  description = "The id of the bastion ec2"
  value       = module.eks.bastion_host_ip
}

output "acm_certificate_arn" {
  description = "ARN of ACM certificate"
  value       = aws_acm_certificate.this.arn
}
