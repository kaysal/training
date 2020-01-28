# Specify the provider and access details
provider "aws" {
    region = "${var.region}"
    access_key = "${var.access_key}"
    secret_key = "${var.secret_key}"
}


# Create a VPC to launch our instances into
resource "aws_vpc" "vpc" {
    cidr_block = "${var.cidr_block}"
    enable_dns_support = "${var.enable_dns_support}"
    enable_dns_hostnames = "${var.enable_dns_hostnames}"
    tags {
        Name = "${var.name}-demo"
    }
}

# Create a public subnet to laucnh our instances into
resource "aws_subnet" "public_subnet" {
    vpc_id = "${aws_vpc.vpc.id}"
    cidr_block = "${var.public_subnet}"
    availability_zone = "${var.zone}"
    tags {
        Name = "${var.name}-public-subnet"
    }
}

resource "aws_eip" "eip_aws_host_1" {
  instance = "${aws_instance.aws_host_1.id}"
  vpc      = true
}

resource "aws_eip" "eip_aws_host_2" {
  instance = "${aws_instance.aws_host_2.id}"
  vpc      = true
}

# Create an internet gateway to give our subnets access to the outside world
resource "aws_internet_gateway" "vpc-igw" {
    vpc_id = "${aws_vpc.vpc.id}"
    tags {
        Name = "${var.name}-igw"
    }
}

# Grant the VPC internet access on its main route table
resource "aws_route" "igw-route" {
    route_table_id = "${aws_vpc.vpc.main_route_table_id}"
    destination_cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.vpc-igw.id}"
}

# Create a VPN Gateway
resource "aws_vpn_gateway" "vpc-vgw" {
    vpc_id = "${aws_vpc.vpc.id}"
    tags {
        Name = "${var.name}-vgw"
    }
}

# Grant the VPC access to the VPN gateway on its main route table
resource "aws_route" "vgw-route" {
    route_table_id = "${aws_vpc.vpc.main_route_table_id}"
    destination_cidr_block = "${var.gcp_cidr}"
    gateway_id = "${aws_vpn_gateway.vpc-vgw.id}"
}

# Create the remote customer gateway profile
resource "aws_customer_gateway" "vpc-cgw" {
    bgp_asn = "${var.vpn_bgp_asn}"
    ip_address = "${var.vpn_ip_address}"
    type = "ipsec.1"
    tags {
        Name = "${var.name}-cgw"
    }
}

# Create the VPN tunnel to customer gateway
resource "aws_vpn_connection" "vpc-vpn" {
    vpn_gateway_id = "${aws_vpn_gateway.vpc-vgw.id}"
    customer_gateway_id = "${aws_customer_gateway.vpc-cgw.id}"
    type = "ipsec.1"
    static_routes_only = true
    tunnel1_preshared_key = "${var.preshared_key}"
    tunnel2_preshared_key = "${var.preshared_key}"
    tags {
        Name = "${var.name}-vpn"
    }
}

# define a static route between a VPN connection and a customer gateway
# create a route to GCP subnet
resource "aws_vpn_connection_route" "gcp_route" {
  destination_cidr_block = "172.16.10.0/24"
  vpn_connection_id      = "${aws_vpn_connection.vpc-vpn.id}"
}

# Our default security group to access
# the instances over SSH and ICMP
resource "aws_security_group" "external_sg" {
  name        = "sg_external"
  vpc_id      = "${aws_vpc.vpc.id}"

  # external ssh access over the internet
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "internal_sg" {
  name        = "sg_internal"
  vpc_id      = "${aws_vpc.vpc.id}"

  # internal tcp and icmp access within aws subnet
  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["${var.cidr_block}"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["${var.cidr_block}"]
  }
}

resource "aws_security_group" "vpn_sg" {
  name        = "sg_vpn"
  vpc_id      = "${aws_vpc.vpc.id}"

  # internal tcp and icmp access within aws subnet
  ingress {
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = ["${var.gcp_cidr}"]
  }
  ingress {
    from_port   = -1
    to_port     = -1
    protocol    = "icmp"
    cidr_blocks = ["${var.gcp_cidr}"]
  }
  egress {
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = ["${var.gcp_cidr}"]
  }
  egress {
    from_port   = -1
    to_port     = -1
    protocol    = "icmp"
    cidr_blocks = ["${var.gcp_cidr}"]
  }
}

# Create the instance
resource "aws_instance" "aws_host_1" {
  instance_type = "t2.micro"

  # Lookup the correct AMI based on the region specified
  ami = "${lookup(var.amis, var.region)}"

  # The name of SSH keypair you've created and downloaded from the AWS console.
  key_name = "${var.key_name}"

  # Our Security group to allow SSH and ICMP access
  vpc_security_group_ids = [
    "${aws_security_group.external_sg.id}",
    "${aws_security_group.internal_sg.id}",
    "${aws_security_group.vpn_sg.id}"
  ]
  subnet_id = "${aws_subnet.public_subnet.id}"

  #Instance tags
  tags {
    Name = "${var.name}-aws-host-1"
  }
}

resource "aws_instance" "aws_host_2" {
  instance_type = "t2.micro"

  # Lookup the correct AMI based on the region specified
  ami = "${lookup(var.amis, var.region)}"

  # The name of SSH keypair you've created and downloaded from the AWS console.
  key_name = "${var.key_name}"

  # Our Security group to allow SSH and ICMP access
  vpc_security_group_ids = [
    "${aws_security_group.external_sg.id}",
    "${aws_security_group.internal_sg.id}",
    "${aws_security_group.vpn_sg.id}"
  ]
  subnet_id = "${aws_subnet.public_subnet.id}"

  #Instance tags
  tags {
    Name = "${var.name}-aws-host-2"
  }
}
