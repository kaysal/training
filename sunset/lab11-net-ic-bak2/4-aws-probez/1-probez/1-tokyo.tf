
locals {
  aws_tokyo_init = templatefile("scripts/probe-asia.sh.tpl", {
    MQTT      = local.gcp.mqtt_tcp_proxy_vip.address
    GCLB      = local.gcp.gclb_vip.address
    GCLB_STD  = local.gcp.gclb_vip_standard.address
    GCLB_PREM = local.gcp.gclb_vip_premium.address
    HOST      = var.global.app_host
  })
}

# ec2

resource "aws_instance" "tokyo_ec2" {
  provider               = aws.tokyo
  instance_type          = "t2.micro"
  availability_zone      = var.aws.tokyo.zone
  ami                    = local.aws.tokyo.ami_ubuntu
  key_name               = local.aws.tokyo.key.id
  subnet_id              = local.aws.tokyo.subnet.id
  vpc_security_group_ids = [local.aws.tokyo.sg.id]
  user_data              = local.aws_tokyo_init

  tags = {
    Name  = "salawu-live-demo"
    OWNER = "salawu"
  }
}

# eip

resource "aws_eip_association" "tokyo_ec2" {
  provider      = aws.tokyo
  instance_id   = aws_instance.tokyo_ec2.id
  allocation_id = local.aws.tokyo.eip.id
}
