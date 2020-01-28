#! /bin/bash

apt update
apt install -y tcpdump

sh -c "echo 1 > /proc/sys/net/ipv4/ip_forward"
iptables -A FORWARD -i eth1 -j ACCEPT
iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE
