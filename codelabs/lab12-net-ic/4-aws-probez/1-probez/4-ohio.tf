
locals {
  aws_ohio_init = templatefile("scripts/probe-us.sh.tpl", {
    MQTT     = local.gcp.mqtt_tcp_proxy_vip.address
    GCLB     = local.gcp.gclb_vip.address
    GCLB_STD = local.gcp.gclb_standard_vip.address
    HOST     = var.global.host
  })
}

# ec2

resource "aws_instance" "ohio_ec2" {
  provider               = aws.ohio
  instance_type          = "t2.micro"
  availability_zone      = var.aws.ohio.zone
  ami                    = local.aws.ohio.ami_ubuntu
  key_name               = local.aws.ohio.key.id
  subnet_id              = local.aws.ohio.subnet.id
  vpc_security_group_ids = [local.aws.ohio.sg.id]
  user_data              = local.aws_ohio_init

  tags = {
    Name  = "salawu-live-demo"
    OWNER = "salawu"
  }
}

# eip

resource "aws_eip_association" "ohio_ec2" {
  provider      = aws.ohio
  instance_id   = aws_instance.ohio_ec2.id
  allocation_id = local.aws.ohio.eip.id
}
