path_to_private_key = "bastion-host-prod-key.pem"  ### Provide local machine Path where bastion host private key is located

env = "prod"

infra_backend_bucket_name  = "terraform-state-prod"
infra_state_file_path      = "prod/infrastructure/terraform.tfstate" 
region                     = "ca-central-1"