
# tokyo
#------------------------------

# vpc

resource "aws_vpc" "tokyo_vpc" {
  provider             = aws.tokyo
  cidr_block           = var.aws.tokyo.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true
  tags = {
    Name  = "salawu-live-demo"
    OWNER = "salawu"
  }
}

# subnet

resource "aws_subnet" "tokyo_subnet" {
  provider                = aws.tokyo
  vpc_id                  = aws_vpc.tokyo_vpc.id
  availability_zone       = var.aws.tokyo.zone
  cidr_block              = var.aws.tokyo.subnet_cidr
  map_public_ip_on_launch = false

  tags = {
    Name  = "salawu-live-demo"
    OWNER = "salawu"
  }
}


# london
#------------------------------

# vpc

resource "aws_vpc" "london_vpc" {
  cidr_block           = var.aws.london.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true
  tags = {
    Name  = "salawu-live-demo"
    OWNER = "salawu"
  }
}

# subnet

resource "aws_subnet" "london_subnet" {
  vpc_id                  = aws_vpc.london_vpc.id
  availability_zone       = var.aws.london.zone
  cidr_block              = var.aws.london.subnet_cidr
  map_public_ip_on_launch = false

  tags = {
    Name  = "salawu-live-demo"
    OWNER = "salawu"
  }
}


# ohio
#------------------------------

# vpc

resource "aws_vpc" "ohio_vpc" {
  provider             = aws.ohio
  cidr_block           = var.aws.ohio.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true
  tags = {
    Name  = "salawu-live-demo"
    OWNER = "salawu"
  }
}

# subnet

resource "aws_subnet" "ohio_subnet" {
  provider                = aws.ohio
  vpc_id                  = aws_vpc.ohio_vpc.id
  availability_zone       = var.aws.ohio.zone
  cidr_block              = var.aws.ohio.subnet_cidr
  map_public_ip_on_launch = false

  tags = {
    Name  = "salawu-live-demo"
    OWNER = "salawu"
  }
}


# singapore
#------------------------------

# vpc

resource "aws_vpc" "singapore_vpc" {
  provider             = aws.singapore
  cidr_block           = var.aws.singapore.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true
  tags = {
    Name  = "salawu-live-demo"
    OWNER = "salawu"
  }
}

# subnet

resource "aws_subnet" "singapore_subnet" {
  provider                = aws.singapore
  vpc_id                  = aws_vpc.singapore_vpc.id
  availability_zone       = var.aws.singapore.zone
  cidr_block              = var.aws.singapore.subnet_cidr
  map_public_ip_on_launch = false

  tags = {
    Name  = "salawu-live-demo"
    OWNER = "salawu"
  }
}

/*
# canada
#------------------------------

# vpc

resource "aws_vpc" "canada_vpc" {
  provider             = aws.canada
  cidr_block           = var.aws.canada.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true
  tags = {
    Name  = "salawu-live-demo"
    OWNER = "salawu"
  }
}

# subnet

resource "aws_subnet" "canada_subnet" {
  provider                = aws.canada
  vpc_id                  = aws_vpc.canada_vpc.id
  availability_zone       = var.aws.canada.zone
  cidr_block              = var.aws.canada.subnet_cidr
  map_public_ip_on_launch = false

  tags = {
    Name  = "salawu-live-demo"
    OWNER = "salawu"
  }
}*/
