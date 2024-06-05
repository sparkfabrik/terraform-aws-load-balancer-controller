locals {
  helm_chart_name = "aws-load-balancer-controller"
  final_namespace = var.create_namespace ? resource.kubernetes_namespace_v1.this[0].metadata[0].name : data.kubernetes_namespace_v1.this[0].metadata[0].name
  k8s_common_labels = merge(
    var.k8s_default_labels,
    var.k8s_additional_labels,
  )

  crd_files = [
    "crd-ingressclassparams.yml",
    "crd-targetgroupbindings.yml",
  ]
  crd_files_processed = { for f in local.crd_files : f => "${path.module}/files/${f}" }
}

# Kubernetes Namespace
resource "kubernetes_namespace_v1" "this" {
  count = var.create_namespace ? 1 : 0

  metadata {
    labels = merge(
      local.k8s_common_labels,
      {
        name = var.namespace
      }
    )
    name = var.namespace
  }
}

data "kubernetes_namespace_v1" "this" {
  count = var.create_namespace ? 0 : 1

  metadata {
    name = var.namespace
  }
}

# AWS Resources
# https://github.com/kubernetes-sigs/aws-load-balancer-controller/blob/main/docs/install/iam_policy.json
resource "aws_iam_policy" "this" {
  name        = var.aws_lbc_iam_policy_name
  description = var.aws_lbc_iam_policy_description
  policy      = file("${path.module}/files/iam_policy.json")
}

module "iam_assumable_role_with_oidc_for_lbc" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-assumable-role-with-oidc"
  version = "~> 5.0"

  create_role      = true
  role_name        = var.aws_lbc_role_name
  role_policy_arns = [aws_iam_policy.this.arn]
  provider_url     = var.cluster_oidc_issuer_host
  oidc_fully_qualified_subjects = [
    "system:serviceaccount:${local.final_namespace}:${var.k8s_lbc_service_account_name}"
  ]
}

# Kubernetes Service Account
resource "kubernetes_service_account_v1" "this" {
  metadata {
    name      = var.k8s_lbc_service_account_name
    namespace = local.final_namespace
    labels    = local.k8s_common_labels
    annotations = {
      "eks.amazonaws.com/role-arn" = module.iam_assumable_role_with_oidc_for_lbc.iam_role_arn
    }
  }
}

resource "kubernetes_secret_v1" "this" {
  metadata {
    namespace = local.final_namespace
    labels    = local.k8s_common_labels
    annotations = {
      "kubernetes.io/service-account.name" = kubernetes_service_account_v1.this.metadata[0].name
    }
    generate_name = "${kubernetes_service_account_v1.this.metadata[0].name}-"
  }

  type                           = "kubernetes.io/service-account-token"
  wait_for_service_account_token = true
}

# Install the CRDs, if required.
resource "kubernetes_manifest" "this" {
  for_each = var.install_crds ? local.crd_files_processed : {}

  manifest = yamldecode(file(each.value))

  field_manager {
    force_conflicts = true
  }
}

resource "helm_release" "this" {
  name             = var.helm_release_name
  repository       = "https://aws.github.io/eks-charts"
  chart            = local.helm_chart_name
  version          = var.helm_chart_version
  namespace        = local.final_namespace
  create_namespace = false

  values = concat(
    [
      templatefile(
        "${path.module}/files/values.yml.tftpl",
        {
          k8s_common_labels    = local.k8s_common_labels
          replica_count        = var.replica_count
          cluster_name         = var.cluster_name
          service_account_name = kubernetes_service_account_v1.this.metadata[0].name
          region               = var.aws_region
          vpc_id               = var.aws_vpc_id
          enable_cert_manager  = var.enable_cert_manager

          set_topology_spread_constraints                    = var.set_topology_spread_constraints
          set_topology_spread_constraints_max_skew           = var.set_topology_spread_constraints_max_skew
          set_topology_spread_constraints_topology_key       = var.set_topology_spread_constraints_topology_key
          set_topology_spread_constraints_when_unsatisfiable = var.set_topology_spread_constraints_when_unsatisfiable

          # Variables for creating the selector labels.
          # If you use `nameOverride` in your values, you should use that instead of `chart_name`.
          # See how the Helm chart creates the selector labels.
          chart_name   = local.helm_chart_name
          release_name = var.helm_release_name
        }
      ),
    ],
    var.helm_additional_values
  )

  depends_on = [kubernetes_manifest.this]
}
