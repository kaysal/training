
# tokyo
#------------------------------

# security group

resource "aws_security_group" "tokyo_sg" {
  provider = aws.tokyo
  name     = "salawu-live-demo"
  vpc_id   = aws_vpc.tokyo_vpc.id

  tags = {
    Name  = "salawu-live-demo"
    OWNER = "salawu"
  }
}

# ssh ingress

resource "aws_security_group_rule" "tokyo_allow_ssh" {
  provider          = aws.tokyo
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.tokyo_sg.id
}

# all egress

resource "aws_security_group_rule" "tokyo_allow_egress" {
  provider          = aws.tokyo
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.tokyo_sg.id
}


# london
#------------------------------

# security group

resource "aws_security_group" "london_sg" {
  name   = "salawu-live-demo"
  vpc_id = aws_vpc.london_vpc.id

  tags = {
    Name  = "salawu-live-demo"
    OWNER = "salawu"
  }
}

# ssh ingress

resource "aws_security_group_rule" "london_allow_ssh" {
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.london_sg.id
}

# all egress

resource "aws_security_group_rule" "london_allow_egress" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.london_sg.id
}

# singapore
#------------------------------

# security group

resource "aws_security_group" "singapore_sg" {
  provider = aws.singapore
  name     = "salawu-live-demo"
  vpc_id   = aws_vpc.singapore_vpc.id

  tags = {
    Name  = "salawu-live-demo"
    OWNER = "salawu"
  }
}

# ssh ingress

resource "aws_security_group_rule" "singapore_allow_ssh" {
  provider          = aws.singapore
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.singapore_sg.id
}

# all egress

resource "aws_security_group_rule" "singapore_allow_egress" {
  provider          = aws.singapore
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.singapore_sg.id
}

# ohio
#------------------------------

# security group

resource "aws_security_group" "ohio_sg" {
  provider = aws.ohio
  name     = "salawu-live-demo"
  vpc_id   = aws_vpc.ohio_vpc.id

  tags = {
    Name  = "salawu-live-demo"
    OWNER = "salawu"
  }
}

# ssh ingress

resource "aws_security_group_rule" "ohio_allow_ssh" {
  provider          = aws.ohio
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.ohio_sg.id
}

# all egress

resource "aws_security_group_rule" "ohio_allow_egress" {
  provider          = aws.ohio
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.ohio_sg.id
}
