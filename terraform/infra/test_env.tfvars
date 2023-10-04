####### AWS 
aws_region = "ca-central-1"

basename = "test"

bucket_arn = "" 

###### VPC
vpc_cidr = "10.1.0.0/16"

route_cidr = "0.0.0.0/0"

public_subnet_list = {
    public-1 = {
        index = 0
        az = "ca-central-1a"
        cidr = "10.1.1.0/24"
    }
    public-2 = {
        index = 1
        az = "ca-central-1b"
        cidr = "10.1.2.0/24"
    }
    public-3 = {
        index = 2
        az = "ca-central-1d"
        cidr = "10.1.3.0/24"
    }
}

private_subnet_list = {
    private-1 = {
        index = 0
        az = "ca-central-1a"
        cidr = "10.1.16.0/20"
    }
    private-2 = {
        index = 1
        az = "ca-central-1b"
        cidr = "10.1.32.0/20"
    }
    private-3 = {
        index = 2
        az = "ca-central-1d"
        cidr = "10.1.48.0/20"
    }
}

eks_node_volume_size = 200
eks_node_volume_type = "gp3"

cluster_name       = "cluster"
cluster_version    = "1.27"

eks_node_ami_type = "AL2_x86_64"
eks_node_disk_size              = 200
eks_node_instance_type          =  ["t2.large"]
eks_node_instance_capacity_type = "ON_DEMAND"

eks_node_minimum_number  = 3
eks_node_maximum_number  = 3

cluster_endpoint_private_access = true
cluster_endpoint_public_access = false

########### Bastion Host ##########

bastion_name                    = "bastion"
bastion_ami_id                  = "ami-0ea18256de20ecdfc"
bastion_instance_type           = "t2.micro"
bastion_key                     = "bastion-host-key"


########### ECR ###########

ecr_repo_name = "ecr-repo"
image_tag_mutability = "MUTABLE"

route53_domain_name = "test.net"