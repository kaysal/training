
output "aws" {
  value = {
    tokyo = {
      vpc    = aws_vpc.tokyo_vpc
      eip    = aws_eip.tokyo_eip
      subnet = aws_subnet.tokyo_subnet
      sg     = aws_security_group.tokyo_sg
      key    = aws_key_pair.tokyo
    }
    london = {
      vpc    = aws_vpc.london_vpc
      eip    = aws_eip.london_eip
      subnet = aws_subnet.london_subnet
      sg     = aws_security_group.london_sg
      key    = aws_key_pair.london
    }
    singapore = {
      vpc    = aws_vpc.singapore_vpc
      eip    = aws_eip.singapore_eip
      subnet = aws_subnet.singapore_subnet
      sg     = aws_security_group.singapore_sg
      key    = aws_key_pair.singapore
    }
    ohio = {
      vpc    = aws_vpc.ohio_vpc
      eip    = aws_eip.ohio_eip
      subnet = aws_subnet.ohio_subnet
      sg     = aws_security_group.ohio_sg
      key    = aws_key_pair.ohio
    }
  }
  sensitive = true
}
