#! /bin/bash

apt update
apt install -y tcpdump dnsutils

sh -c "echo 1 > /proc/sys/net/ipv4/ip_forward"
iptables -t nat -A POSTROUTING -o eth0 -d ${REMOTE_NS_IP} -j SNAT --to-source ${proxy_ip}
iptables -A PREROUTING -t nat -i eth0 -d ${proxy_ip} -p udp --dport 53 -j DNAT --to ${remote_ns_ip}
iptables -A PREROUTING -t nat -i eth0 -d ${proxy_ip} -p tcp --dport 53 -j DNAT --to ${remote_ns_ip}
