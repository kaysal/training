
# gcp
#---------------------------------

variable "project_id" {
  description = "Project ID"
}

variable "global" {
  description = "variable map to hold all global config values"
  type        = any
}

variable "hub" {
  description = "variable map for main project"
  type        = any
}

variable "spoke" {
  description = "variable map for peer project"
  type        = any
}


# aws
#---------------------------------

variable "public_key_path" {
  description = "path to public key for ec2 SSH"
}

variable "access_key" {}
variable "secret_key" {}
