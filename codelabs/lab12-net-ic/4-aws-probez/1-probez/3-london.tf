
locals {
  aws_london_init = templatefile("scripts/probe-eu.sh.tpl", {
    MQTT     = local.gcp.mqtt_tcp_proxy_vip.address
    GCLB     = local.gcp.gclb_vip.address
    GCLB_STD = local.gcp.gclb_standard_vip.address
    HOST     = var.global.host
  })
}

# ec2

resource "aws_instance" "london_ec2" {
  instance_type          = "t2.micro"
  availability_zone      = var.aws.london.zone
  ami                    = local.aws.london.ami_ubuntu
  key_name               = local.aws.london.key.id
  subnet_id              = local.aws.london.subnet.id
  vpc_security_group_ids = [local.aws.london.sg.id]
  user_data              = local.aws_london_init

  tags = {
    Name  = "salawu-live-demo"
    OWNER = "salawu"
  }
}

# eip

resource "aws_eip_association" "london_ec2" {
  instance_id   = aws_instance.london_ec2.id
  allocation_id = local.aws.london.eip.id
}
