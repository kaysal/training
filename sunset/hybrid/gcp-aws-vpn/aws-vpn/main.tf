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

# Create a private subnet to laucnh our DB into
resource "aws_subnet" "private" {
    vpc_id = "${aws_vpc.vpc.id}"
    cidr_block = "${var.private_subnet}"
    availability_zone = "${var.zone}"
    tags {
        Name = "${var.name}-private-subnet"
    }
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
    destination_cidr_block = "${var.vpn_dst_cidr_block}"
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
# create a route to GCP loadbalancer subnet
resource "aws_vpn_connection_route" "gcp_route_lb" {
  destination_cidr_block = "172.16.10.0/24"
  vpn_connection_id      = "${aws_vpn_connection.vpc-vpn.id}"
}

# create a route to GCP test subnet
resource "aws_vpn_connection_route" "gcp_route_test" {
  destination_cidr_block = "172.16.1.0/24"
  vpn_connection_id      = "${aws_vpn_connection.vpc-vpn.id}"
}

# Our default security group to access
# the instances over SSH and ICMP
resource "aws_security_group" "default" {
  name        = "vpn_security_group"
  vpc_id      = "${aws_vpc.vpc.id}"

  # ICMP access from remote GCP loadbalancer subnet
  # containing web server frontends
  ingress {
    from_port   = 8
    to_port     = 0
    protocol    = "icmp"
    cidr_blocks = ["${var.gcp_lb_cidr}"]
  }

}

# Create the instance
resource "aws_instance" "oracle_db" {
  instance_type = "t2.micro"

  # Lookup the correct AMI based on the region
  # we specified
  ami = "${lookup(var.amis, var.region)}"

  # The name of our SSH keypair you've created and downloaded
  # from the AWS console.
  # https://console.aws.amazon.com/ec2/v2/home?region=eu-west-1#KeyPairs:
  key_name = "${var.key_name}"

  # Our Security group to allow SSH and ICMP access
  vpc_security_group_ids = ["${aws_security_group.default.id}"]
  subnet_id              = "${aws_subnet.private.id}"
  //user_data              = "${file("userdata.sh")}"

  #Instance tags
  tags {
    Name = "${var.name}-instance"
  }
}
