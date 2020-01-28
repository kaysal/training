
variable "public_key_path" {
  description = "path to public key for ec2 SSH"
}

variable "aws" {
  description = "map for all aws variables"
  type        = any
}
