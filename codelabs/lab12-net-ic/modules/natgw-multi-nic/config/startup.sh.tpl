#! /bin/bash

sh -c "echo 1 > /proc/sys/net/ipv4/ip_forward"

iptables -A FORWARD -i eth0 -o eth1 -j ACCEPT
iptables -A FORWARD -i eth1 -o eth0 -j ACCEPT

iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE

ifconfig eth1 ${TRUST_IP} netmask 255.255.255.255 broadcast ${TRUST_IP} mtu 1430
echo "1 rt1" | sudo tee -a /etc/iproute2/rt_tables
ip route add ${TRUST_IP_DGW} src ${TRUST_IP} dev eth1 table rt1
ip route add default via ${TRUST_IP_DGW} dev eth1 table rt1
ip rule add from ${TRUST_IP}/32 table rt1
ip rule add to ${TRUST_IP}/32 table rt1
ip rule add to 192.168.0.0/16 table rt1
ip rule add to 172.16.0.0/12 table rt1
ip rule add to 10.0.0.0/8 table rt1
