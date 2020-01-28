# provider
provider "google" {
  project     = "${var.project_name}"
  credentials = "${file("${var.credentials_file_path}")}"
  region  = "us-east1"
}

terraform {
  backend "gcs" {
    bucket  = "tf-shk"
    prefix  = "states/hybrid-gcp-aws/gcp/us-east1/"
    credentials ="/home/salawu/Terraform/credentials/gcp-credentials-tf.json"
  }
}

# remote state files for aws tunnel data
data "terraform_remote_state" "aws_us_east1_vpc1_data" {
  backend = "gcs"
  config {
    bucket  = "tf-shk"
    prefix  = "states/hybrid-gcp-aws/aws/us-east1/vpc1"
    credentials ="/home/salawu/Terraform/credentials/gcp-credentials-tf.json"
  }
}

# Retrieve vpn gateway external IP addresses
#--------------------------------------
data "google_compute_address" "gcp_us_e1_vpn_gw1_ip" {
  name = "gcp-us-e1-vpn-gw1-ip"
}

data "google_compute_address" "gcp_us_e1_vpn_gw2_ip" {
  name = "gcp-us-e1-vpn-gw2-ip"
}

# existing vpc data form gcp
data "google_compute_network" "vpc" {
  name  = "${var.name}-vpc"
}

# existing subnetwork data form gcp
data "google_compute_subnetwork" "us_e1_subnet_10_50_10" {
  name   = "${var.name}-us-e1-subnet-10-50-10"
}
