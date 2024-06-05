variable "aws_region" {
  description = "The AWS region where the cluster is deployed."
  type        = string
}

variable "aws_vpc_id" {
  description = "The ID of the VPC where the AWS Load Balancer Controller will be deployed."
  type        = string
}

variable "cluster_name" {
  description = "The name of the EKS cluster."
  type        = string
}

variable "cluster_oidc_issuer_host" {
  description = "The OIDC issuer host for the EKS cluster."
  type        = string
}
