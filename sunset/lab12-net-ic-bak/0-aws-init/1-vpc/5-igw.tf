
# tokyo

resource "aws_internet_gateway" "tokyo_igw" {
  provider = aws.tokyo
  vpc_id   = aws_vpc.tokyo_vpc.id

  tags = {
    Name  = "salawu-live-demo"
    OWNER = "salawu"
  }
}

# london

resource "aws_internet_gateway" "london_igw" {
  vpc_id = aws_vpc.london_vpc.id

  tags = {
    Name  = "salawu-live-demo"
    OWNER = "salawu"
  }
}

# singapore

resource "aws_internet_gateway" "singapore_igw" {
  provider = aws.singapore
  vpc_id   = aws_vpc.singapore_vpc.id

  tags = {
    Name  = "salawu-live-demo"
    OWNER = "salawu"
  }
}

# ohio

resource "aws_internet_gateway" "ohio_igw" {
  provider = aws.ohio
  vpc_id   = aws_vpc.ohio_vpc.id

  tags = {
    Name  = "salawu-live-demo"
    OWNER = "salawu"
  }
}
