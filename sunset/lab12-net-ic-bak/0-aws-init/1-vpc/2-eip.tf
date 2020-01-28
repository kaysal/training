
# tokyo

resource "aws_eip" "tokyo_eip" {
  provider = aws.tokyo
  vpc      = "true"

  tags = {
    Name  = "salawu-live-demo"
    OWNER = "salawu"
  }
}

# ohio

resource "aws_eip" "ohio_eip" {
  provider = aws.ohio
  vpc      = "true"

  tags = {
    Name  = "salawu-live-demo"
    OWNER = "salawu"
  }
}

# london

resource "aws_eip" "london_eip" {
  vpc = "true"

  tags = {
    Name  = "salawu-live-demo"
    OWNER = "salawu"
  }
}

# singapore

resource "aws_eip" "singapore_eip" {
  provider = aws.singapore
  vpc      = "true"

  tags = {
    Name  = "salawu-live-demo"
    OWNER = "salawu"
  }
}

# canada

resource "aws_eip" "canada_eip" {
  provider = aws.canada
  vpc      = "true"

  tags = {
    Name  = "salawu-live-demo"
    OWNER = "salawu"
  }
}
