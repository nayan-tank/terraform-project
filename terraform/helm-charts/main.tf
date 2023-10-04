data "terraform_remote_state" "infra" {
  backend = "s3"
  config = {
    bucket = var.infra_backend_bucket_name
    key    = var.infra_state_file_path
    region = var.region
  }
}

####### ACM
resource "local_file" "acm_update_nginx_cert" {
 content = templatefile("../../utils/${var.env}-nginx-custom-values.yaml",
   {
     acm_certificate_arn = data.terraform_remote_state.infra.outputs.acm_certificate_arn
   }
 )
 filename = "template_output/${var.env}-nginx-custom-values.yaml"
}


resource "null_resource" "copy_helm_charts" {
  connection {
    type        = "ssh"
    user        = "ubuntu"
    private_key = file("${var.path_to_private_key}")
    host        = data.terraform_remote_state.infra.outputs.bastion_host_ip
  }

  provisioner "remote-exec" {
    inline = [
      "rm -rf /home/ubuntu/terraform-eks-addons || true",
      "mkdir -p /home/ubuntu/terraform-eks-addons/utils"
    ]
  }

  provisioner "file" {
    source      = "addons/"
    destination = "/home/ubuntu/terraform-eks-addons"
  }

  provisioner "file" {
    source      = "../../utils"
    destination = "/home/ubuntu/terraform-eks-addons"
  }

  provisioner "file" {
    source      = "template_output/${var.env}-nginx-custom-values.yaml"
    destination = "/home/ubuntu/terraform-eks-addons/utils/${var.env}-nginx-custom-values.yaml"
  }

  provisioner "remote-exec" {
    inline = [
      "cd /home/ubuntu/terraform-eks-addons",
      "kubectl apply -f utils/ebs_storage_class.yaml && kubectl apply -f utils/ebs_storage_class_delete.yaml && kubectl apply -f utils/metrics-server.yaml && kubectl apply -f utils/${var.env}-clamAV.yaml",
      "terraform init -backend-config='${var.env}_env_backend.conf' && terraform apply -no-color -auto-approve -input=false -var-file='${var.env}_env.tfvars'",
      "terraform taint null_resource.get_karpenter_charts && kubectl apply -f utils/${var.env}-karpenter-provisioner.yaml"
    ]
  }
}
