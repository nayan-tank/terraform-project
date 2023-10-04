path_to_private_key = "bastion-host-dev-key.pem"  ### Provide local machine Path where bastion host private key is located

env = "dev"

infra_backend_bucket_name  = "dev-ca-tfstate"
infra_state_file_path      = "dev/infrastructure/terraform.tfstate" 
region                     = "ca-central-1"