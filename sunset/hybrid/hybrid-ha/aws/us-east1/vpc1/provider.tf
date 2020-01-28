# Specify the provider and access details
provider "aws" {
  region     = "us-east-1"
  access_key = "${var.access_key}"
  secret_key = "${var.secret_key}"
}

terraform {
  backend "gcs" {
    bucket  = "tf-shk"
    prefix  = "states/hybrid-gcp-aws/aws/us-east1/vpc1/"
    credentials ="/home/salawu/Terraform/credentials/gcp-credentials-tf.json"
  }
}
