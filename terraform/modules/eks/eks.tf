module "eks" {
  source = "terraform-aws-modules/eks/aws"
  version = "19.15.2"
  cluster_name                    = var.cluster_name
  cluster_version                 = var.cluster_version
  cluster_endpoint_private_access = var.cluster_endpoint_private_access
  cluster_endpoint_public_access  = var.cluster_endpoint_public_access

  vpc_id     = var.vpc_id

  subnet_ids = var.subnet_ids

  cluster_addons = {
    aws-ebs-csi-driver = {
      addon_version = "v1.19.0-eksbuild.2"
    }
    coredns = {
      addon_version = "v1.10.1-eksbuild.1"
    }
    kube-proxy = {
      addon_version = "v1.27.1-eksbuild.1"
    }
    vpc-cni = {
      addon_version = "v1.12.6-eksbuild.2"
    }
  }

  # EKS Managed Node Group(s)
  eks_managed_node_group_defaults = {
    ami_type               = var.eks_node_ami_type
    disk_size              = var.eks_node_disk_size
    instance_types         = var.eks_node_instance_type
    capacity_type          = "ON_DEMAND"
  }

  cluster_security_group_additional_rules = {
    egress_nodes_ephemeral_ports_tcp = {
      description                = "VPC API Access"
      protocol                   = "tcp"
      from_port                  = 443
      to_port                    = 443
      type                       = "ingress"
      cidr_blocks                 = [ var.cidr_block ] 
    }
  }
  node_security_group_additional_rules = {
    ingress_self_all = {
      description = "Node to node all ports/protocols"
      protocol    = "tcp"
      from_port   = 443
      to_port     = 443
      type        = "ingress"
      self        = true
    }
    egress_all = {
      description      = "Node all egress"
      protocol         = "-1"
      from_port        = 0
      to_port          = 0
      type             = "egress"
      cidr_blocks      = ["0.0.0.0/0"]
      ipv6_cidr_blocks = ["::/0"]
    }
  }

  eks_managed_node_groups = {
    on-demand = {
      create_launch_template   = false
      launch_template_id     = aws_launch_template.external.id
      launch_template_version  = aws_launch_template.external.default_version
      min_size                 = var.eks_node_minimum_number 
      max_size                 = var.eks_node_maximum_number 
      desired_size             = var.eks_node_minimum_number 

      capacity_type  = var.eks_node_instance_capacity_type
      
      tags = {
        environment = "${var.basename}"
      }
    }
  }
}


# AWS LAUNCH TEMPLATE FOR EKS NODE
resource "aws_launch_template" "external" {
  name_prefix            = "external-"
  description            = "EKS managed node group external launch template"
  update_default_version = true

  block_device_mappings {
    device_name = "/dev/xvda"

    ebs {
      volume_size           = var.eks_node_volume_size
      volume_type           = var.eks_node_volume_type
      # iops                  = 3000
      # throughput            = 125
      encrypted             = true
      delete_on_termination = true
    }
  }

  tag_specifications {
    resource_type = "instance"

    tags = {
      Name      = "eks-on-demand"
      "karpenter.sh/discovery" = var.cluster_name
    }
  }

  tag_specifications {
    resource_type = "volume"

    tags = {
      Name      = "eks-on-demand"
    }
  }

  tags = {
    environment = "${var.basename}-env"
  }

  lifecycle {
    create_before_destroy = true
  }
}


# EKS NODE SECURITY GROUP
resource "aws_security_group" "bastion_sg" {
  name        = "sg"
  description = "Allow TLS inbound traffic"
  vpc_id      = var.vpc_id

  ingress {
    description      = "SSH"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "${var.basename}-bastion-sg"
  }
}

# EBS CSI policy attachment to Node role

resource "aws_iam_role_policy_attachment" "additional-ebs-csi" {
  for_each = module.eks.eks_managed_node_groups
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"
  role       = each.value.iam_role_name
}

# Locals
locals {
  kubeconfig = <<-YAML
apiVersion: v1
clusters:
- cluster:
    certificate-authority-data: ${module.eks.cluster_certificate_authority_data}
    server: ${module.eks.cluster_endpoint}
  name: ${module.eks.cluster_name}
contexts:
- context:
    cluster: ${module.eks.cluster_name}
    user: kubectl_access
    namespace: default
  name: ${module.eks.cluster_name}
current-context: ${module.eks.cluster_name}
kind: Config
preferences: {}
users:
- name: kubectl_access
  user:
    exec:
      apiVersion: client.authentication.k8s.io/v1beta1
      args:
      - --region
      - ${var.aws_region}
      - eks
      - get-token
      - --cluster-name
      - ${module.eks.cluster_name}
      command: aws
  YAML
}


# Role Policy
resource "aws_iam_policy" "bastion_host_eks_full_access" {
  name        = "bastion_host_eks_full_access"
  path        = "/"
  description = "Bastion Host EKS Full Access Policy"
  policy = jsonencode(
    {
      "Version": "2012-10-17",
      "Statement": [
          {
              "Sid": "VisualEditor0",
              "Effect": "Allow",
              "Action": "eks:*",
              "Resource": "*"
          },
          {
              "Effect": "Allow",
              "Action": [
                  "s3:GetObject",
                  "s3:PutObject",
                  "s3:ListBucket"
              ],
              "Resource": [
                  "${var.bucket_arn}",
                  "${var.bucket_arn}/*"
              ]
          }
      ]
    }
  )
}

# Bastion Host IAM Role 
resource "aws_iam_role" "bastion_ec2_eks_full_access_role" {
  name = "bastion_ec2_eks_full_access_role"
  assume_role_policy = file("${path.module}/ec2-policy.json")
}

# Role Attachment 
resource "aws_iam_role_policy_attachment" "ec2_eks_policy_attachment" {
  role       = aws_iam_role.bastion_ec2_eks_full_access_role.name
  policy_arn = aws_iam_policy.bastion_host_eks_full_access.arn
}


# Create an IAM instance profile
resource "aws_iam_instance_profile" "bastion_instance_profile" {
  name = "bastion-host-instance-profile"
  role = aws_iam_role.bastion_ec2_eks_full_access_role.name
}

# Bastion Host
resource "aws_instance" "bastion_host" {
  ami           = var.bastion_ami_id
  instance_type = var.bastion_instance_type
  subnet_id     = var.bastion_subnet_id
  vpc_security_group_ids    = [aws_security_group.bastion_sg.id]
  key_name             = var.bastion_key
  associate_public_ip_address = true
  iam_instance_profile =  aws_iam_instance_profile.bastion_instance_profile.id
  
  tags = {
    Name = "${var.basename}-${var.bastion_name}"
  }

  root_block_device {
    volume_size   = 20
    encrypted = true
  }

  user_data = templatefile("${path.module}/templates/bastion_userdata.tftpl", {
    kubeconfig = local.kubeconfig
    cluster_version   = var.cluster_version
  })

}


module "addone_irsa_role" {
  source    = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"

  role_name                          = "${var.basename}-eks-addons-iam-role"
  
  attach_vpc_cni_policy = true
  vpc_cni_enable_ipv4   = true

  attach_karpenter_controller_policy = true
  attach_external_dns_policy = true
  attach_efs_csi_policy  = true
  attach_load_balancer_controller_policy = true


  karpenter_controller_cluster_name         = module.eks.cluster_name
  karpenter_controller_node_iam_role_arns = [module.eks.eks_managed_node_groups["on-demand"].iam_role_arn]

  oidc_providers = {
    main = {
      provider_arn               = module.eks.oidc_provider_arn

      namespace_service_accounts = ["karpenter:karpenter-sa", "external-dns:external-dns", "kube-system:efs-csi-controller-sa", "kube-system:efs-csi-node-sa", "kube-system:aws-load-balancer-controller", "kube-system:aws-node"]

    }
  }
}
