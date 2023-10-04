path_to_private_key = "bastion-host-test-key.pem"  ### Provide local machine Path where bastion host private key is located

env = "test"

infra_backend_bucket_name  = "terraform-state-test"
infra_state_file_path      = "test/infrastructure/terraform.tfstate" 
region                     = "ca-central-1"