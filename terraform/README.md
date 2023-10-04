## How to run Terraform stack
 1. open local terminal/powershell
 2. Go to terraform/infra directory
 3. Export AWS credentials based on your terminal type.
 
    For Linux/MAC OS terminal,
        
    ```
    export AWS_ACCESS_KEY_ID="SAMPLEID"
    export AWS_SECRET_ACCESS_KEY="SAMPLEKEY"
    export AWS_DEFAULT_REGION="ca-central-1"
    ```

    For Powershell,
    
    ```
    $Env:AWS_ACCESS_KEY_ID="SAMPLEID"
    $Env:AWS_SECRET_ACCESS_KEY="SAMPLEID"
    $Env:AWS_DEFAULT_REGION="ca-central-1"
    ```
 4. Run Below TF commands to create stack
     ```
     terraform init -backend-config="dev_env_backend.conf"
     terraform plan -out=tfplan -var-file="dev_env.tfvars"
     terraform apply -no-color -input=false tfplan
     #terraform destroy -auto-approve -var-file="dev_env.tfvars" ##incase you want to destroy stack
     ```
Note down the outputs section of Terraform output. We will use those output values in AddOn installation section.

#### NOTE : The utils/test-nginx-custom-values.yaml file will be automatically modified after the stack is created, leave it as is and do not commit that file anywhere.

Sample output below.
```
Apply complete! Resources: 0 added, 3 changed, 0 destroyed.

Outputs:

aws_region = "ca-central-1"
bastion_host_id = "i-0017d78067a45cbdd"
bastion_host_ip = "3.96.57.51"
cluster_endpoint = "https://5D926DBCCA12FEF534AE2B4D6BDDDE04.gr7.ca-central-1.eks.amazonaws.com"
cluster_iam_role_name = "on-demand-eks-node-group-20230810064141125600000008"
cluster_name = "dev-cluster"
efs_id = "fs-012197ef673af3c4d"
irsa_iam_role_arn = "arn:aws:iam::404150791765:role/dev-eks-addons-iam-role"
irsa_iam_role_name = "dev-eks-addons-iam-role"
```

## Bastion Setup
Once the terraform apply is successful. You need to perform below steps.

Login to the bastion (jumpbox )EC2 instance using pem key.
Create ~/.aws/credentials file to put your AWS access_key_id and secret_access_key as shown below.

```
[user1]
aws_access_key_id=AKIAI44QH8DHBEXAMPLE
aws_secret_access_key=je7MtGbClwBF/2Zp9Utk/h3yCo8nvbEXAMPLEKEY
```

Now execute below command to edit configmap aws-auth to assign permission to EC2 with service account role.

```
ubuntu@ip-10-1-2-230:~/.aws$ AWS_PROFILE=user1 kubectl edit cm aws-auth -n kube-system
```

Add below text block in configmap under mapRoles section (replace the account number to the one deploying the infrastructure into):

```
- rolearn: arn:aws:iam::404150791765:role/bastion_ec2_eks_full_access_role
      username: ubuntu
      groups:
        - system:masters
```

Save the configmap file.
Now you should be able to access kubernetes API from bastion host without your personal credentials. Go to .aws/credentials to destroy your personal credentials. Logout from Bastion host.



## POST Terraform AddOns Configuration
 1. open local terminal/powershell
 2. Go to terraform/helm-charts directory
 3. Export AWS credentials based on your terminal type.
 
    For Linux/MAC OS terminal,
        
    ```
    export AWS_ACCESS_KEY_ID="SAMPLEID"
    export AWS_SECRET_ACCESS_KEY="SAMPLEKEY"
    export AWS_DEFAULT_REGION="ca-central-1"
    ```

    For Powershell,
    
    ```
    $Env:AWS_ACCESS_KEY_ID="SAMPLEID"
    $Env:AWS_SECRET_ACCESS_KEY="SAMPLEID"
    $Env:AWS_DEFAULT_REGION="ca-central-1"
    ```
    
 4. __Now setup bastion host credential in dev_env.tfvars, provide local machine Path where bastion host private key is located.__
 5. __Find the Karpenter Provisioner yaml found in the utils directory of this repo. Verify the instanceProfile value and modify if required.__
 6. Run Below TF commands to create stack
 
     ```
     terraform init
     terraform plan -out=tfplan -var-file="dev_env.tfvars" 
     terraform apply -no-color -input=false tfplan 
     #terraform destroy -auto-approve -var-file="dev_env.tfvars" ##incase you want to destroy stack
     ```
     NOTE: To remove/modify helm charts, you will need to delete the .terraform folder located in the /terraform/helm-charts directory, then repeat the steps above.  Otherwise the provisioner will simply copy the modified files without applying them.
     NOTE: This stack (terraform state) will be created on local machine and no need to save it. The actual Terraform state for AddOns Configuration will be stored in S3 bucket.