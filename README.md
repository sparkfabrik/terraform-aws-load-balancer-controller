# Terraform AWS Load Balancer Controller

This module installs the AWS Load Balancer Controller into an EKS cluster using Helm.

This module follows the [AWS Load Balancer Controller installation guide using Helm](https://docs.aws.amazon.com/eks/latest/userguide/lbc-helm.html). The required resources are created using terraform. We use the same naming conventions as the guide and the same default values.

## How to migrate from installation made using the plain manifest files to this module

As described [here](https://docs.aws.amazon.com/eks/latest/userguide/lbc-remove.html), you can delete the resources for the AWS Load Balancer Controller and the applications that use the Application Load Balancers Ingresses should continue to work. **Remember to keep in place the following resources to avoid disruption:**

- `IngressClassParams` CRD
- `TargetGroupBindings` CRD
- `alb` IngreesClassParams
- `alb` IngressClass

The two CRDs (`IngressClassParams` and `TargetGroupBindings`) will be updated by the two `kubernetes_manifest` of this module. The `alb` IngressClass and `IngressClassParams` will be created by `helm_release` of this module.

The two CRDs should be updated without any issue. **The alb `IngressClass` and `IngressClassParams` must be _adopted_ before applying the `helm_release` of this module**. You can execute the following code snippet to update your resources and inform the Helm release about them:

```bash
# IngressClassParams
kubectl annotate IngressClassParams alb meta.helm.sh/release-name=aws-load-balancer-controller
kubectl annotate IngressClassParams alb meta.helm.sh/release-namespace=kube-system
kubectl label IngressClassParams alb app.kubernetes.io/managed-by=Helm
# IngressClass
kubectl annotate IngressClass alb meta.helm.sh/release-name=aws-load-balancer-controller
kubectl annotate IngressClass alb meta.helm.sh/release-namespace=kube-system
kubectl label IngressClass alb app.kubernetes.io/managed-by=Helm
```

In the snippet above, **if you have changed the `helm_release_name` or `namespace` of this module, you should update the values of the annotations accordingly.**

<!-- BEGIN_TF_DOCS -->

## Providers

| Name                                                                  | Version |
| --------------------------------------------------------------------- | ------- |
| <a name="provider_aws"></a> [aws](#provider_aws)                      | >= 5.0  |
| <a name="provider_helm"></a> [helm](#provider_helm)                   | >= 2.0  |
| <a name="provider_kubernetes"></a> [kubernetes](#provider_kubernetes) | >= 2.23 |

## Requirements

| Name                                                                        | Version |
| --------------------------------------------------------------------------- | ------- |
| <a name="requirement_terraform"></a> [terraform](#requirement_terraform)    | >= 1.5  |
| <a name="requirement_aws"></a> [aws](#requirement_aws)                      | >= 5.0  |
| <a name="requirement_helm"></a> [helm](#requirement_helm)                   | >= 2.0  |
| <a name="requirement_kubernetes"></a> [kubernetes](#requirement_kubernetes) | >= 2.23 |

## Inputs

| Name                                                                                                                                                                                    | Description                                                                                                                                                                                                                  | Type           | Default                                                                                      | Required |
| --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | -------------- | -------------------------------------------------------------------------------------------- | :------: |
| <a name="input_aws_lbc_iam_policy_description"></a> [aws_lbc_iam_policy_description](#input_aws_lbc_iam_policy_description)                                                             | The description of the IAM policy for the AWS Load Balancer Controller.                                                                                                                                                      | `string`       | `"IAM policy for AWS Load Balancer Controller."`                                             |    no    |
| <a name="input_aws_lbc_iam_policy_name"></a> [aws_lbc_iam_policy_name](#input_aws_lbc_iam_policy_name)                                                                                  | The name of the IAM policy for the AWS Load Balancer Controller.                                                                                                                                                             | `string`       | `"AWSLoadBalancerControllerIAMPolicy"`                                                       |    no    |
| <a name="input_aws_lbc_role_name"></a> [aws_lbc_role_name](#input_aws_lbc_role_name)                                                                                                    | The name of the IAM role that the AWS Load Balancer Controller will assume.                                                                                                                                                  | `string`       | `"aws-load-balancer-controller"`                                                             |    no    |
| <a name="input_aws_region"></a> [aws_region](#input_aws_region)                                                                                                                         | The AWS region where the cluster is deployed.                                                                                                                                                                                | `string`       | n/a                                                                                          |   yes    |
| <a name="input_aws_vpc_id"></a> [aws_vpc_id](#input_aws_vpc_id)                                                                                                                         | The ID of the VPC where the AWS Load Balancer Controller will be deployed.                                                                                                                                                   | `string`       | n/a                                                                                          |   yes    |
| <a name="input_cluster_name"></a> [cluster_name](#input_cluster_name)                                                                                                                   | The name of the EKS cluster.                                                                                                                                                                                                 | `string`       | n/a                                                                                          |   yes    |
| <a name="input_cluster_oidc_issuer_host"></a> [cluster_oidc_issuer_host](#input_cluster_oidc_issuer_host)                                                                               | The OIDC issuer host for the EKS cluster.                                                                                                                                                                                    | `string`       | n/a                                                                                          |   yes    |
| <a name="input_create_namespace"></a> [create_namespace](#input_create_namespace)                                                                                                       | Whether to create the namespace or not. If set to false, it is expected that the namespace already exists.                                                                                                                   | `bool`         | `false`                                                                                      |    no    |
| <a name="input_enable_cert_manager"></a> [enable_cert_manager](#input_enable_cert_manager)                                                                                              | Enable cert-manager for the AWS Load Balancer Controller.                                                                                                                                                                    | `bool`         | `false`                                                                                      |    no    |
| <a name="input_helm_additional_values"></a> [helm_additional_values](#input_helm_additional_values)                                                                                     | Additional values to be passed to the Helm chart.                                                                                                                                                                            | `list(string)` | `[]`                                                                                         |    no    |
| <a name="input_helm_chart_version"></a> [helm_chart_version](#input_helm_chart_version)                                                                                                 | The version of the aws-load-balancer-controller Helm chart. Consider the default value the reference version of the module and the base of the values.yaml.tftpl file.                                                       | `string`       | `"1.8.1"`                                                                                    |    no    |
| <a name="input_helm_release_name"></a> [helm_release_name](#input_helm_release_name)                                                                                                    | The name of the Helm release.                                                                                                                                                                                                | `string`       | `"aws-load-balancer-controller"`                                                             |    no    |
| <a name="input_install_crds"></a> [install_crds](#input_install_crds)                                                                                                                   | Install the CRDs for the AWS Load Balancer Controller.                                                                                                                                                                       | `bool`         | `true`                                                                                       |    no    |
| <a name="input_k8s_additional_labels"></a> [k8s_additional_labels](#input_k8s_additional_labels)                                                                                        | Additional labels to apply to the Kubernetes resources.                                                                                                                                                                      | `map(string)`  | `{}`                                                                                         |    no    |
| <a name="input_k8s_default_labels"></a> [k8s_default_labels](#input_k8s_default_labels)                                                                                                 | Labels to apply to the Kubernetes resources. These are opinionated labels, you can add more labels using the variable `additional_k8s_labels`. If you want to remove a label, you can override it with an empty map(string). | `map(string)`  | <pre>{<br> "managed-by": "terraform",<br> "scope": "aws-load-balancer-controller"<br>}</pre> |    no    |
| <a name="input_k8s_lbc_service_account_name"></a> [k8s_lbc_service_account_name](#input_k8s_lbc_service_account_name)                                                                   | The name of the Kubernetes service account for AWS Load Balancer Controller.                                                                                                                                                 | `string`       | `"aws-load-balancer-controller"`                                                             |    no    |
| <a name="input_namespace"></a> [namespace](#input_namespace)                                                                                                                            | The namespace in which the AWS Load Balancer Controller resources will be created.                                                                                                                                           | `string`       | `"kube-system"`                                                                              |    no    |
| <a name="input_replica_count"></a> [replica_count](#input_replica_count)                                                                                                                | The number of replicas for the AWS Load Balancer Controller.                                                                                                                                                                 | `number`       | `2`                                                                                          |    no    |
| <a name="input_set_topology_spread_constraints"></a> [set_topology_spread_constraints](#input_set_topology_spread_constraints)                                                          | Set the topologySpreadConstraints for the AWS Load Balancer Controller.                                                                                                                                                      | `bool`         | `true`                                                                                       |    no    |
| <a name="input_set_topology_spread_constraints_max_skew"></a> [set_topology_spread_constraints_max_skew](#input_set_topology_spread_constraints_max_skew)                               | Set the topologyKey in the topologySpreadConstraints for the AWS Load Balancer Controller.                                                                                                                                   | `number`       | `1`                                                                                          |    no    |
| <a name="input_set_topology_spread_constraints_topology_key"></a> [set_topology_spread_constraints_topology_key](#input_set_topology_spread_constraints_topology_key)                   | Set the topologyKey in the topologySpreadConstraints for the AWS Load Balancer Controller.                                                                                                                                   | `string`       | `"kubernetes.io/hostname"`                                                                   |    no    |
| <a name="input_set_topology_spread_constraints_when_unsatisfiable"></a> [set_topology_spread_constraints_when_unsatisfiable](#input_set_topology_spread_constraints_when_unsatisfiable) | Set the whenUnsatisfiable policy in the topologySpreadConstraints for the AWS Load Balancer Controller.                                                                                                                      | `string`       | `"ScheduleAnyway"`                                                                           |    no    |

## Outputs

| Name                                                                                                     | Description                                                             |
| -------------------------------------------------------------------------------------------------------- | ----------------------------------------------------------------------- |
| <a name="output_aws_lbc_iam_policy_arn"></a> [aws_lbc_iam_policy_arn](#output_aws_lbc_iam_policy_arn)    | The ARN of the IAM policy created for the AWS Load Balancer Controller. |
| <a name="output_final_k8s_common_labels"></a> [final_k8s_common_labels](#output_final_k8s_common_labels) | The final list of common labels to apply to the Kubernetes resources.   |

## Resources

| Name                                                                                                                                        | Type        |
| ------------------------------------------------------------------------------------------------------------------------------------------- | ----------- |
| [aws_iam_policy.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy)                               | resource    |
| [helm_release.this](https://registry.terraform.io/providers/hashicorp/helm/latest/docs/resources/release)                                   | resource    |
| [kubernetes_manifest.this](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/manifest)                     | resource    |
| [kubernetes_namespace_v1.this](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/namespace_v1)             | resource    |
| [kubernetes_secret_v1.this](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/secret_v1)                   | resource    |
| [kubernetes_service_account_v1.this](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/service_account_v1) | resource    |
| [kubernetes_namespace_v1.this](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/data-sources/namespace_v1)          | data source |

## Modules

| Name                                                                                                                                            | Source                                                              | Version |
| ----------------------------------------------------------------------------------------------------------------------------------------------- | ------------------------------------------------------------------- | ------- |
| <a name="module_iam_assumable_role_with_oidc_for_lbc"></a> [iam_assumable_role_with_oidc_for_lbc](#module_iam_assumable_role_with_oidc_for_lbc) | terraform-aws-modules/iam/aws//modules/iam-assumable-role-with-oidc | ~> 5.0  |

<!-- END_TF_DOCS -->
