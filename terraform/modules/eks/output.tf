################################################################################
# Cluster
################################################################################

output "cluster_endpoint" {
  description = "Endpoint for your Kubernetes API server"
  value       = module.eks.cluster_endpoint
}

output "cluster_name" {
  description = "The name of the EKS cluster"
  value       = module.eks.cluster_name
}

output "cluster_iam_role_arn" {
  description = "IAM role arn of the EKS nodegroup"
  value       = module.eks.eks_managed_node_groups["on-demand"].iam_role_arn
}

output "cluster_iam_role_name" {
  description = "IAM role name of the EKS nodegroup"
  value       = module.eks.eks_managed_node_groups["on-demand"].iam_role_name
}

####### IRSA ###########
output "irsa_iam_role_arn" {
  description = "ARN of IRSA IAM role"
  value       = module.addone_irsa_role.iam_role_arn
}

output "irsa_iam_role_name" {
  description = "ARN of IRSA IAM role"
  value       = module.addone_irsa_role.iam_role_name
}

########## bastion host #######
output "role_name" {
  value = aws_iam_role.bastion_ec2_eks_full_access_role.id
}

output "bastion_host_id" {
  description = "The id of the bastion ec2"
  value       = aws_instance.bastion_host.id
}

output "bastion_host_ip" {
  description = "The id of the bastion ec2"
  value       = aws_instance.bastion_host.public_ip
}

output "iam_instance_profile_id" {
  description = "Instance profile's ID"
  value       = try(aws_iam_instance_profile.bastion_instance_profile.id, null)
}