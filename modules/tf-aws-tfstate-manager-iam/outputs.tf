output "allow_read_tfstate_policy_arn" {
  description = "arn of the policy that allows reading tfstate"

  value = aws_iam_policy.allow_read_tfstate.arn
}

output "allow_read_write_tfstate_policy_arn" {
  description = "arn of the policy that allows reading and writing tfstate"

  value = aws_iam_policy.allow_read_write_tfstate.arn
}