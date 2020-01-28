#!/bin/bash -xe
apt-get update
apt-get install strongswan keepalived -y
echo "%any : PSK \"[secret-key]\"" | sudo tee /etc/ipsec.secrets > /dev/null
sh -c "echo 1 > /proc/sys/net/ipv4/ip_forward"
cat <<EOF >>/etc/ipsec.conf

conn %default
  authby=psk
  auto=start
  dpdaction=hold
  esp=aes128-sha1-modp2048!
  forceencaps=yes
  ike=aes128-sha1-modp2048!
  keyexchange=ikev1
  mobike=no
  type=tunnel
  left=%any
  leftid=[VPN_GATEWAY_EXTERNAL_IP_ADDRESS]
  leftsubnet=10.0.0.0/24
  leftauth=psk
  leftikeport=4500
  rightsubnet=[ON_PREM_ADDRESS_SPACE]
  rightauth=psk
  rightikeport=4500

conn aws-tunnel1
  right=[ON_PREM_EXTERNAL_IP_ADDRESS1]

#conn aws-tunnel2
    #right=[ON_PREM_EXTERNAL_IP_ADDRESS2]
EOF
ipsec restart

# some test commands
#-------------------
# sudo ipsec status
# sudo ipsec up aws-tunnel1
# echo | nc -u [vpn-vm-gateway-external-address] 4500
# tcpdump -nn -n host [public-ip-of-local-VPN-gateway-machine] -i any
# ipsec statusall
