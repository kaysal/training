variable "region" {
  default = "europe-west2"
}

variable "region_zone" {
  default = "europe-west2-a"
}

variable "project_name" {
  description = "lb-ipv6"
}

variable "credentials_file_path" {
  description = "C://Users//salawu//SIM//ssh_keys//remote//dedes.pub"
}

variable "public_key_path" {
  description = "Path to SSH public key to be attached to cloud instances"
}

variable "source_service_accounts" {
  description = "GCE service account"
}

variable "preshared_key" {
    description = "preshaed key used for tunnels 1 and 2"
}

variable "remote_cidr" {
    description = "remote cidr ranges"
}
