
locals {
  aws_singapore_init = templatefile("scripts/probe-asia.sh.tpl", {
    MQTT     = local.gcp.mqtt_tcp_proxy_vip.address
    GCLB     = local.gcp.gclb_vip.address
    GCLB_STD = local.gcp.gclb_standard_vip.address
    HOST     = var.global.host
  })
}

# ec2

resource "aws_instance" "singapore_ec2" {
  provider               = aws.singapore
  instance_type          = "t2.micro"
  availability_zone      = var.aws.singapore.zone
  ami                    = local.aws.singapore.ami_ubuntu
  key_name               = local.aws.singapore.key.id
  subnet_id              = local.aws.singapore.subnet.id
  vpc_security_group_ids = [local.aws.singapore.sg.id]
  user_data              = local.aws_singapore_init

  tags = {
    Name  = "salawu-live-demo"
    OWNER = "salawu"
  }
}

# eip

resource "aws_eip_association" "singapore_ec2" {
  provider      = aws.singapore
  instance_id   = aws_instance.singapore_ec2.id
  allocation_id = local.aws.singapore.eip.id
}
