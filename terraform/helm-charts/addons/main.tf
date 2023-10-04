############## EKS CLUSTER  ##############
data "terraform_remote_state" "infra" {
  backend = "s3"
  config = {
    bucket = var.infra_backend_bucket_name
    key    = var.infra_state_file_path
    region = var.region
  }
}


############### AWS EFS CSI DRIVER ###############
resource "helm_release" "aws_efs_csi_driver" {
    name       = "aws-efs-csi-driver"

    repository = "https://kubernetes-sigs.github.io/aws-efs-csi-driver"
    chart      = "aws-efs-csi-driver"

    namespace = "kube-system"

    set {
        name = "image.repository"
        value = var.image_repo
    }
    set {
        name = "controller.serviceAccount.create"
        value = var.create_sa_efs_csi
    }
    set {
        name = "controller.serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"
        value = "${data.terraform_remote_state.infra.outputs.irsa_iam_role_arn}"
        type = "string"
    }
    set {
        name = "controller.serviceAccount.name"
        value = var.efs_csi_sa_name
    }
    set {
        name = "node.serviceAccount.name"
        value = var.node_sa_name
    }
    set {
        name = "node.serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"
        value = "${data.terraform_remote_state.infra.outputs.irsa_iam_role_arn}"
        type = "string"
    }
    set {
        name = "storageClasses[0].name"
        value = "efs-sc"
    }
    set {
        name = "storageClasses[0].annotations.storageclass\\.kubernetes\\.io/is-default-class"
        value = "false"
        type = "string"
    }
    set {
        name = "storageClasses[0].reclaimPolicy"
        value = "Delete"
    }
    set {
        name = "storageClasses[0].volumeBindingMode"
        value = "Immediate"
    }
    set {
        name = "storageClasses[0].parameters.fileSystemId"
        value = data.terraform_remote_state.infra.outputs.efs_id
    }
}


############### KARPENTER ###############

resource "null_resource" "get_karpenter_charts" {
  provisioner "local-exec" {
    command = "export HELM_EXPERIMENTAL_OCI=1 && helm pull ${var.chart_url} --version ${var.chart_version} --untar"
  }
}

resource "helm_release" "karpenter" {
  depends_on = [
    null_resource.get_karpenter_charts, time_sleep.wait_40_seconds,
  ]
  name      = "karpenter"
  namespace = "karpenter"
  chart = "/home/ubuntu/terraform-eks-addons/karpenter"
  create_namespace = true

  set {
      name = "serviceAccount.name"
      value = var.karpenter_sa_name
  }
  set {
      name = "serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"
      value = data.terraform_remote_state.infra.outputs.irsa_iam_role_arn
  }
  set {
      name = "settings.aws.clusterName"
      value = data.terraform_remote_state.infra.outputs.cluster_name 
  }
  set {
      name = "settings.aws.clusterEndpoint"
      value = data.terraform_remote_state.infra.outputs.cluster_endpoint
  }
  set {
      name = "settings.aws.defaultInstanceProfile"
      value = data.terraform_remote_state.infra.outputs.cluster_iam_role_name
  }

}




############### AWS LB CONTROLLER ###############
resource "helm_release" "aws_lb_controller" {

    name       = "aws-load-balancer-controller"

    repository = "https://aws.github.io/eks-charts"
    chart      = "aws-load-balancer-controller"
    namespace = "kube-system"
    set {
        name = "clusterName"
        value = data.terraform_remote_state.infra.outputs.cluster_name 
    }
    set {
        name = "serviceAccount.create"
        value = var.elb_sa_create
    }
    set {
        name = "serviceAccount.name"
        value = var.elb_sa_name
    }
    set {
        name = "serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"
        value = data.terraform_remote_state.infra.outputs.irsa_iam_role_arn
    }

}


############### EXTERNAL DNS ###############

resource "helm_release" "external_dns" {
    name       = "external-dns"

    repository = "https://kubernetes-sigs.github.io/external-dns"
    chart      = "external-dns"
    namespace = "external-dns"
    create_namespace = true
    version = "1.13.0"
    
    set {
        name = "serviceAccount.name"
        value = var.ext_dns_sa_name
    }
    set {
        name = "serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"
        value = data.terraform_remote_state.infra.outputs.irsa_iam_role_arn
    }
    set {
        name = "txtOwnerId"
        value = var.txtOwnerId
    }
    set {
        name = "domainFilters"
        value = var.domain_filters
    }
    set {
        name = "aws.zoneType"
        value = var.aws_zone_type
    }

}


############## NGINX ################

variable "env" {
  type        = string
  description = "Allows different nginx config files for each environment."
}

resource "time_sleep" "wait_40_seconds" {
  depends_on = [
    helm_release.aws_lb_controller,
  ]
  create_duration = "40s"
}

resource "helm_release" "nginx" {

    depends_on = [
      time_sleep.wait_40_seconds,
    ]
    name       = "nginx"
    repository = "https://helm.nginx.com/stable"
    chart      = "nginx-ingress"
    namespace = "ingress"
    create_namespace = true
    version = "0.18.1"
    timeout    = 600 
    values = [
        file("utils/${var.env}-nginx-custom-values.yaml")
    ]
}


############# Grafana/Prometheus ################

resource "helm_release" "kube_prometheus_stack" {
    name       = "kube-prometheus-stack"
    repository = "https://prometheus-community.github.io/helm-charts"
    chart      = "kube-prometheus-stack"
    namespace = "monitoring"
    create_namespace = true
    version = "51.1.0"
    values = [
        file("utils/${var.env}-prometheus-stack-values.yaml")
    ]

    depends_on = [ helm_release.nginx ]
}