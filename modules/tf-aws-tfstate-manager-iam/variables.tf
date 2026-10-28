variable "s3_bucket_arn" {
  type        = string
  description = "s3 bucket storing state files"
}

variable "dynamodb_table_arn" {
  type        = string
  description = "dynamodb table locking state"
}

variable "dynamodb_table_kms_key_id" {
  type        = string
  description = "kms key id used to encrypt the dynamodb table locking state"
  default     = null
}