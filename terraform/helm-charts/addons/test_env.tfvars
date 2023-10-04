############## Infra State backend ##############

infra_backend_bucket_name  = "terraform-state-test"
infra_state_file_path      = "test/infrastructure/terraform.tfstate" 
region                     = "ca-central-1"

############### AWS EFS CSI DRIVER ###############
image_repo = "1234567890.dkr.ecr.ca-central-1.amazonaws.com/eks/aws-efs-csi-driver"
create_sa_efs_csi = true
efs_csi_sa_name = "efs-csi-controller-sa"
node_sa_name = "efs-csi-node-sa"


############### KARPENTER #############
karpenter_sa_name = "karpenter-sa"
chart_url     = "oci://public.ecr.aws/karpenter/karpenter"
chart_version = "v0.28.0"

############### AWS LB CONTROLLER #################
elb_sa_create = true
elb_sa_name = "aws-load-balancer-controller"


############## EXTERNAL DNS ################
ext_dns_sa_name = "external-dns"
txtOwnerId = "externaldns"
aws_zone_type = "public"
# domain_filters = ["automation.net", ]
domain_filters = "{test.net}"

############## NGINX ###################
env = "test"
