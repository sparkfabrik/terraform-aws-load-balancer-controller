output "final_k8s_common_labels" {
  description = "The final list of common labels to apply to the Kubernetes resources."
  value       = local.k8s_common_labels
}

output "aws_lbc_iam_policy_arn" {
  description = "The ARN of the IAM policy created for the AWS Load Balancer Controller."
  value       = aws_iam_policy.this.arn
}
