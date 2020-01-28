
# provider

provider "aws" {
  region = "eu-west-2"
}

provider "aws" {
  alias  = "tokyo"
  region = "ap-northeast-1"
}

provider "aws" {
  alias  = "ohio"
  region = "us-east-2"
}

provider "aws" {
  alias  = "singapore"
  region = "ap-southeast-1"
}

provider "aws" {
  alias  = "canada"
  region = "ca-central-1"
}

# remote state
#--------------------------

# gcp

data "terraform_remote_state" "gcp_hub_vpc1" {
  backend = "local"

  config = {
    path = "../../1-gcp-hub/1-vpc1/1-vpc/terraform.tfstate"
  }
}

# aws

data "terraform_remote_state" "aws_init" {
  backend = "local"

  config = {
    path = "../../0-aws-init/1-vpc/terraform.tfstate"
  }
}

data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name = "name"

    #values = ["ubuntu/images/hvm-ssd/ubuntu-bionic-18.04-amd64-server-*"]
    values = ["ubuntu/images/hvm-ssd/ubuntu-xenial-16.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}

locals {
  gcp = {
    gclb_vip           = data.terraform_remote_state.gcp_hub_vpc1.outputs.gclb_vip
    gclb_standard_vip  = data.terraform_remote_state.gcp_hub_vpc1.outputs.gclb_standard_vip
    mqtt_tcp_proxy_vip = data.terraform_remote_state.gcp_hub_vpc1.outputs.mqtt_tcp_proxy_vip
  }
  aws = {
    tokyo = {
      ami_ubuntu = "ami-0cd744adeca97abb1"
      subnet     = data.terraform_remote_state.aws_init.outputs.aws.tokyo.subnet
      eip        = data.terraform_remote_state.aws_init.outputs.aws.tokyo.eip
      sg         = data.terraform_remote_state.aws_init.outputs.aws.tokyo.sg
      key        = data.terraform_remote_state.aws_init.outputs.aws.tokyo.key
    }
    singapore = {
      ami_ubuntu = "ami-061eb2b23f9f8839c"
      subnet     = data.terraform_remote_state.aws_init.outputs.aws.singapore.subnet
      eip        = data.terraform_remote_state.aws_init.outputs.aws.singapore.eip
      sg         = data.terraform_remote_state.aws_init.outputs.aws.singapore.sg
      key        = data.terraform_remote_state.aws_init.outputs.aws.singapore.key
    }
    london = {
      ami_ubuntu = "ami-0be057a22c63962cb"
      subnet     = data.terraform_remote_state.aws_init.outputs.aws.london.subnet
      eip        = data.terraform_remote_state.aws_init.outputs.aws.london.eip
      sg         = data.terraform_remote_state.aws_init.outputs.aws.london.sg
      key        = data.terraform_remote_state.aws_init.outputs.aws.london.key
    }
    ohio = {
      ami_ubuntu = "ami-0d5d9d301c853a04a"
      subnet     = data.terraform_remote_state.aws_init.outputs.aws.ohio.subnet
      eip        = data.terraform_remote_state.aws_init.outputs.aws.ohio.eip
      sg         = data.terraform_remote_state.aws_init.outputs.aws.ohio.sg
      key        = data.terraform_remote_state.aws_init.outputs.aws.ohio.key
    }
  }
}
