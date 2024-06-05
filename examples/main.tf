module "example" {
  source  = "github.com/sparkfabrik/terraform-aws-load-balancer-controller"
  version = ">= 0.1.0"

  aws_region               = var.aws_region
  aws_vpc_id               = var.aws_vpc_id
  cluster_name             = var.cluster_name
  cluster_oidc_issuer_host = var.cluster_oidc_issuer_host
}
