
# tokyo

resource "aws_route_table" "tokyo_public_rt" {
  provider = aws.tokyo
  vpc_id   = aws_vpc.tokyo_vpc.id

  tags = {
    Name  = "salawu-live-demo"
    OWNER = "salawu"
  }
}

resource "aws_route_table_association" "tokyo_public" {
  provider       = aws.tokyo
  subnet_id      = aws_subnet.tokyo_subnet.id
  route_table_id = aws_route_table.tokyo_public_rt.id
}

resource "aws_route" "tokyo_public_internet_route" {
  provider               = aws.tokyo
  route_table_id         = aws_route_table.tokyo_public_rt.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.tokyo_igw.id
}

# london

resource "aws_route_table" "london_public_rt" {
  vpc_id = aws_vpc.london_vpc.id

  tags = {
    Name  = "salawu-live-demo"
    OWNER = "salawu"
  }
}

resource "aws_route_table_association" "london_public" {
  subnet_id      = aws_subnet.london_subnet.id
  route_table_id = aws_route_table.london_public_rt.id
}

resource "aws_route" "london_public_internet_route" {
  route_table_id         = aws_route_table.london_public_rt.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.london_igw.id
}

# singapore

resource "aws_route_table" "singapore_public_rt" {
  provider = aws.singapore
  vpc_id   = aws_vpc.singapore_vpc.id

  tags = {
    Name  = "salawu-live-demo"
    OWNER = "salawu"
  }
}

resource "aws_route_table_association" "singapore_public" {
  provider       = aws.singapore
  subnet_id      = aws_subnet.singapore_subnet.id
  route_table_id = aws_route_table.singapore_public_rt.id
}

resource "aws_route" "singapore_public_internet_route" {
  provider               = aws.singapore
  route_table_id         = aws_route_table.singapore_public_rt.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.singapore_igw.id
}

# ohio

resource "aws_route_table" "ohio_public_rt" {
  provider = aws.ohio
  vpc_id   = aws_vpc.ohio_vpc.id

  tags = {
    Name  = "salawu-live-demo"
    OWNER = "salawu"
  }
}

resource "aws_route_table_association" "ohio_public" {
  provider       = aws.ohio
  subnet_id      = aws_subnet.ohio_subnet.id
  route_table_id = aws_route_table.ohio_public_rt.id
}

resource "aws_route" "ohio_public_internet_route" {
  provider               = aws.ohio
  route_table_id         = aws_route_table.ohio_public_rt.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.ohio_igw.id
}
