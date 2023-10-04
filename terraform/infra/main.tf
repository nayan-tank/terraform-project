module "vpc" {
    source = "./../modules/vpc"
    vpc_cidr = var.vpc_cidr
    basename = var.basename
    cluster_name = var.cluster_name
    public_subnet_list = var.public_subnet_list
    private_subnet_list = var.private_subnet_list
}

module "eks" {
  source = "./../modules/eks"
  subnet_ids = module.vpc.private_subnet_ids_list
  vpc_id = module.vpc.vpc_id
  cidr_block = var.vpc_cidr
  basename = var.basename
  bucket_arn = var.bucket_arn 
  cluster_name                    = "${var.basename}-${var.cluster_name}"
  cluster_version                 = var.cluster_version
  eks_node_minimum_number = 3
  eks_node_maximum_number = 3
  eks_node_volume_size = var.eks_node_volume_size
  eks_node_volume_type = var.eks_node_volume_type
  eks_node_disk_size = var.eks_node_disk_size
  eks_node_ami_type = var.eks_node_ami_type
  eks_node_instance_type = var.eks_node_instance_type
  eks_node_instance_capacity_type = var.eks_node_instance_capacity_type
  cluster_endpoint_public_access = var.cluster_endpoint_public_access
  cluster_endpoint_private_access = var.cluster_endpoint_private_access

  bastion_subnet_id = module.vpc.public_subnet_2
  bastion_name = var.bastion_name
  bastion_key = var.bastion_key
  aws_region = var.aws_region
  bastion_ami_id = var.bastion_ami_id
  bastion_instance_type = var.bastion_instance_type
  
}

module "efs" {
  source      = "./../modules/efs"
  vpc_id = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnet_ids_list
  basename    = var.basename
  transition_to_ia_days = 90
  efs_performance_mode = "generalPurpose"
  efs_throughput_mode = "bursting"
}



module "ecr" {
  source = "./../modules/ecr"
  ecr_repo_name = var.ecr_repo_name
  image_tag_mutability = var.image_tag_mutability
}