variable "project_name" {
  description = "slurm-hpc-optimized"
}

variable "credentials_file_path" {
  description = "path for gcp authentication credentials"
}

variable "public_key_path" {
  description = "Path to SSH public key to be attached to cloud instances"
}

variable "private_key_path" {
  description = "Path to SSH private key"
}

variable "preshared_key" {
  description = "preshaed key used for tunnels 1 and 2"
}

variable "name" {
    description = "The name of the VPC."
    default = "strongswan"
}
