# Create VPC to launch our instances into
resource "aws_vpc" "eu_w1_vpc1" {
  cidr_block           = "${var.eu_w1_vpc1_cidr}"
  enable_dns_hostnames = "false"
  enable_dns_support   = "true"

  tags {
    Name = "${var.name}-eu-w1-vpc1"
  }
}

# Create subnets to launch instances into
resource "aws_subnet" "eu_w1_vpc1_172_16_10" {
  availability_zone       = "eu-west-1a"
  vpc_id                  = "${aws_vpc.eu_w1_vpc1.id}"
  cidr_block              = "${var.eu_w1_vpc1_172_16_10}"
  map_public_ip_on_launch = "true"

  tags {
    Name = "${var.name}-eu-w1-vpc1-172-16-10"
  }
}

resource "aws_subnet" "eu_w1_vpc1_172_16_11" {
  availability_zone       = "eu-west-1b"
  vpc_id                  = "${aws_vpc.eu_w1_vpc1.id}"
  cidr_block              = "${var.eu_w1_vpc1_172_16_11}"
  map_public_ip_on_launch = "true"

  tags {
    Name = "${var.name}-eu-w1-vpc1-172-16-11"
  }
}

# Create vpc internet gateway
resource "aws_internet_gateway" "eu_w1_vpc1_igw" {
  vpc_id = "${aws_vpc.eu_w1_vpc1.id}"

  tags {
    Name = "${var.name}-eu-w1-vpc1-igw"
  }
}

# Grant the VPC internet access on its main route table
resource "aws_route" "eu_w1_vpc1_igw_route" {
  route_table_id         = "${aws_vpc.eu_w1_vpc1.main_route_table_id}"
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = "${aws_internet_gateway.eu_w1_vpc1_igw.id}"
}

# Enable the VPGW to propagate BGP learned routes
# to the routing tables of a VPC
resource "aws_vpn_gateway_route_propagation" "eu_w1_vpc1_vpgw_route_prop" {
  vpn_gateway_id = "${aws_vpn_gateway.eu_w1_vpc1_vpgw.id}"
  route_table_id = "${aws_vpc.eu_w1_vpc1.main_route_table_id}"
}
