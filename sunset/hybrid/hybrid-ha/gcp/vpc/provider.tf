
provider "google" {
  project     = "${var.project_name}"
  credentials = "${file("${var.credentials_file_path}")}"
}

terraform {
  backend "gcs" {
    bucket  = "tf-shk"
    prefix  = "states/hybrid-gcp-aws/gcp/vpc/"
    credentials ="/home/salawu/Terraform/credentials/gcp-credentials-shk.json"
  }
}
