/**
* # tf-aws-tfstate-manager-iam
* 
* The purpose of this module is to create aws iam policies with the capability to manage terraform state stored in an S3 backend.
* 
* ## Usage
* 
* See [referencing a GitLab terraform module registry module](https://docs.gitlab.com/ee/user/packages/terraform_module_registry/#reference-a-terraform-module).
* 
* ```tf
* module "tfstate_manager_iam" {
*     source = "gitlab.example.com/engineering/tf-aws-tfstate-manager-iam/aws"
*     version = "1.0.0"
* 
*     s3_bucket_arn = <arn>
*     dynamodb_table_arn = <arn>
*     dynamodb_table_kms_key_id = "alias/aws/dynamodb"
* 
*     context = module.this.context
* }
* ```
*/

data "aws_kms_key" "dynamodb_table" {
  count  = var.dynamodb_table_kms_key_id != null ? 1 : 0
  key_id = var.dynamodb_table_kms_key_id
}

data "aws_iam_policy_document" "allow_read_tfstate" {
  statement {
    effect = "Allow"
    actions = [
      "s3:ListBucket"
    ]
    resources = [
      var.s3_bucket_arn
    ]
    condition {
      test     = "StringLike"
      variable = "aws:userAgent"
      values   = ["*Terraform*"]
    }
  }
  statement {
    effect = "Allow"
    actions = [
      "s3:GetObject"
    ]
    resources = [
      var.s3_bucket_arn,
      "${var.s3_bucket_arn}/*"
    ]
    condition {
      test     = "StringLike"
      variable = "aws:userAgent"
      values   = ["*Terraform*"]
    }
  }
  statement {
    effect = "Allow"
    actions = [
      "dynamodb:GetItem",
      "dynamodb:PutItem",
      "dynamodb:DeleteItem",
      "dynamodb:Describe*",
      "dynamodb:List*"
    ]
    resources = [
      var.dynamodb_table_arn
    ]
    condition {
      test     = "StringLike"
      variable = "aws:userAgent"
      values   = ["*Terraform*"]
    }
  }
  dynamic "statement" {
    for_each = var.dynamodb_table_kms_key_id != null ? [1] : []
    content {
      effect = "Allow"
      actions = [
        "kms:Decrypt"
      ]
      resources = [
        one(data.aws_kms_key.dynamodb_table[*].arn)
      ]
    }
  }
}

module "allow_read_tfstate_label" {
  source  = "cloudposse/label/null"
  version = "0.25.0"

  attributes = [
    "allow-read-tfstate"
  ]

  context = module.this.context
}


resource "aws_iam_policy" "allow_read_tfstate" {
  name        = module.allow_read_tfstate_label.id
  description = "allows reading terraform state"

  policy = data.aws_iam_policy_document.allow_read_tfstate.json

  tags = module.allow_read_tfstate_label.tags
}

data "aws_iam_policy_document" "allow_read_write_tfstate" {
  statement {
    effect = "Allow"
    actions = [
      "s3:ListBucket"
    ]
    resources = [
      var.s3_bucket_arn
    ]
    condition {
      test     = "StringLike"
      variable = "aws:userAgent"
      values   = ["*Terraform*"]
    }
  }
  statement {
    effect = "Allow"
    actions = [
      "s3:GetObject",
      "s3:PutObject",
      "s3:DeleteObject"
    ]
    resources = [
      var.s3_bucket_arn,
      "${var.s3_bucket_arn}/*"
    ]
    condition {
      test     = "StringLike"
      variable = "aws:userAgent"
      values   = ["*Terraform*"]
    }
  }
  statement {
    effect = "Allow"
    actions = [
      "s3:GetObject",
      "s3:PutObject",
      "s3:DeleteObject"
    ]
    resources = [
      var.s3_bucket_arn,
      "${var.s3_bucket_arn}/*"
    ]
    condition {
      test     = "StringLike"
      variable = "aws:userAgent"
      values   = ["*Terraform*"]
    }
  }

  statement {
    effect = "Allow"
    actions = [
      "dynamodb:GetItem",
      "dynamodb:PutItem",
      "dynamodb:DeleteItem",
      "dynamodb:Describe*",
      "dynamodb:List*"
    ]
    resources = [
      var.dynamodb_table_arn
    ]
    condition {
      test     = "StringLike"
      variable = "aws:userAgent"
      values   = ["*Terraform*"]
    }
  }

  dynamic "statement" {
    for_each = var.dynamodb_table_kms_key_id != null ? [1] : []
    content {
      effect = "Allow"
      actions = [
        "kms:Decrypt"
      ]
      resources = [
        one(data.aws_kms_key.dynamodb_table[*].arn)
      ]
    }
  }
}

module "allow_read_write_tfstate_label" {
  source  = "cloudposse/label/null"
  version = "0.25.0"

  attributes = [
    "allow-read-write-tfstate"
  ]

  context = module.this.context
}

resource "aws_iam_policy" "allow_read_write_tfstate" {
  name        = module.allow_read_write_tfstate_label.id
  description = "allows reading and writing tfstate"

  policy = data.aws_iam_policy_document.allow_read_write_tfstate.json

  tags = module.allow_read_write_tfstate_label.tags
}
