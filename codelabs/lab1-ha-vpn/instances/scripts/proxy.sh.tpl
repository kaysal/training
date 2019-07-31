#! /bin/bash

apt update
apt install -y tcpdump dnsutils

sh -c "echo 1 > /proc/sys/net/ipv4/ip_forward"
iptables -t nat -A POSTROUTING -o eth0 -j SNAT --to-source ${SNAT}
iptables -A PREROUTING -t nat -i eth0 -d ${DEST} -j DNAT --to ${DNAT}
