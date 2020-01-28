#! /bin/bash

apt update
apt install -y tcpdump dnsutils

sh -c "echo 1 > /proc/sys/net/ipv4/ip_forward"

iptables -t nat -A POSTROUTING -o eth0 -d ${HUB_EU1_DNS_INBOUND} -j SNAT --to-source ${ONPREM_EU1_PROXY}
iptables -A PREROUTING -t nat -i eth0 -d ${ONPREM_EU1_PROXY} -p udp --dport 53 -j DNAT --to ${HUB_EU1_DNS_INBOUND}
iptables -A PREROUTING -t nat -i eth0 -d ${ONPREM_EU1_PROXY} -p tcp --dport 53 -j DNAT --to ${HUB_EU1_DNS_INBOUND}
