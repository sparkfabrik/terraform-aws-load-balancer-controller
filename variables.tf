variable "namespace" {
  description = "The namespace in which the AWS Load Balancer Controller resources will be created."
  type        = string
  default     = "kube-system"
}

variable "create_namespace" {
  description = "Whether to create the namespace or not. If set to false, it is expected that the namespace already exists."
  type        = bool
  default     = false
}

variable "helm_release_name" {
  description = "The name of the Helm release."
  type        = string
  default     = "aws-load-balancer-controller"
}

variable "helm_chart_version" {
  description = "The version of the aws-load-balancer-controller Helm chart. Consider the default value the reference version of the module and the base of the values.yaml.tftpl file."
  type        = string
  default     = "1.8.1"
}

variable "helm_additional_values" {
  description = "Additional values to be passed to the Helm chart."
  type        = list(string)
  default     = []
}

variable "k8s_default_labels" {
  description = "Labels to apply to the Kubernetes resources. These are opinionated labels, you can add more labels using the variable `additional_k8s_labels`. If you want to remove a label, you can override it with an empty map(string)."
  type        = map(string)
  default = {
    managed-by = "terraform"
    scope      = "aws-load-balancer-controller"
  }
}

variable "k8s_additional_labels" {
  description = "Additional labels to apply to the Kubernetes resources."
  type        = map(string)
  default     = {}
}

variable "k8s_lbc_service_account_name" {
  description = "The name of the Kubernetes service account for AWS Load Balancer Controller."
  type        = string
  default     = "aws-load-balancer-controller"
}

variable "aws_region" {
  description = "The AWS region where the cluster is deployed."
  type        = string
}

variable "aws_vpc_id" {
  description = "The ID of the VPC where the AWS Load Balancer Controller will be deployed."
  type        = string
}

variable "aws_lbc_iam_policy_name" {
  description = "The name of the IAM policy for the AWS Load Balancer Controller."
  type        = string
  default     = "AWSLoadBalancerControllerIAMPolicy"
}

variable "aws_lbc_iam_policy_description" {
  description = "The description of the IAM policy for the AWS Load Balancer Controller."
  type        = string
  default     = "IAM policy for AWS Load Balancer Controller."
}

variable "aws_lbc_role_name" {
  description = "The name of the IAM role that the AWS Load Balancer Controller will assume."
  type        = string
  default     = "aws-load-balancer-controller"
}

variable "cluster_name" {
  description = "The name of the EKS cluster."
  type        = string
}

variable "cluster_oidc_issuer_host" {
  description = "The OIDC issuer host for the EKS cluster."
  type        = string
}

variable "install_crds" {
  description = "Install the CRDs for the AWS Load Balancer Controller."
  type        = bool
  default     = true
}

variable "enable_cert_manager" {
  description = "Enable cert-manager for the AWS Load Balancer Controller."
  type        = bool
  default     = false
}

variable "replica_count" {
  description = "The number of replicas for the AWS Load Balancer Controller."
  type        = number
  default     = 2
}

variable "set_topology_spread_constraints" {
  description = "Set the topologySpreadConstraints for the AWS Load Balancer Controller."
  type        = bool
  default     = true
}

variable "set_topology_spread_constraints_max_skew" {
  description = "Set the topologyKey in the topologySpreadConstraints for the AWS Load Balancer Controller."
  type        = number
  default     = 1
}

variable "set_topology_spread_constraints_topology_key" {
  description = "Set the topologyKey in the topologySpreadConstraints for the AWS Load Balancer Controller."
  type        = string
  default     = "kubernetes.io/hostname"
}

variable "set_topology_spread_constraints_when_unsatisfiable" {
  description = "Set the whenUnsatisfiable policy in the topologySpreadConstraints for the AWS Load Balancer Controller."
  type        = string
  default     = "ScheduleAnyway"
}
