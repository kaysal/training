#! /bin/bash

apt update
apt install -y tcpdump fping dnsutils libxml2-utils apache2-utils

sh -c "echo 1 > /proc/sys/net/ipv4/ip_forward"
sysctl -w net.ipv4.conf.all.forwarding=1

iptables -A FORWARD -i eth0 -o eth1 -j ACCEPT
iptables -A FORWARD -i eth1 -o eth0 -j ACCEPT

iptables -t nat -A POSTROUTING -o eth0 -d ${ONPREM_UNBOUND} -j SNAT --to-source ${HUB_PROXY}
iptables -A PREROUTING -t nat -i eth0 -d ${HUB_PROXY} -p udp --dport 53 -j DNAT --to ${ONPREM_UNBOUND}
iptables -A PREROUTING -t nat -i eth0 -d ${HUB_PROXY} -p tcp --dport 53 -j DNAT --to ${ONPREM_UNBOUND}

ifconfig eth1 ${PROXY_IPX} netmask 255.255.255.255 broadcast ${PROXY_IPX} mtu 1430
echo "1 rt1" | sudo tee -a /etc/iproute2/rt_tables

ip route add ${DGW_IPX} src ${PROXY_IPX} dev eth1 table rt1
ip route add default via ${DGW_IPX} dev eth1 table rt1
ip rule add to ${PROXY_IPX}/32 table rt1
ip rule add from ${PROXY_IPX}/32 table rt1

ip rule add to ${SVC_EU1_CIDR} table rt1
ip rule add to ${SVC_EU2_CIDR} table rt1
ip rule add to ${SVC_ASIA1_CIDR} table rt1
ip rule add to ${SVC_ASIA2_CIDR} table rt1
ip rule add to ${SVC_US1_CIDR} table rt1
ip rule add to ${SVC_US2_CIDR} table rt1
ip rule add to ${TRAFFIC_DIR_VIP} table rt1

mkdir /var/temp
touch /var/temp/dns_list.txt
cat <<EOF > /var/temp/dns_list.txt
proxy.eu.onprem.lab
vm.asia.onprem.lab
vm.us.onprem.lab
proxy.eu1.hub.lab
proxy.eu2.hub.lab
proxy.asia1.hub.lab
proxy.asia2.hub.lab
proxy.us1.hub.lab
proxy.us2.hub.lab
vm.eu1.svc.lab
vm.eu2.svc.lab
vm.asia1.svc.lab
vm.asia2.svc.lab
vm.us1.svc.lab
vm.us2.svc.lab
EOF

touch /usr/local/bin/pinger
chmod a+x /usr/local/bin/pinger
cat <<EOF > /usr/local/bin/pinger
  fping -A -f /var/temp/dns_list.txt
EOF

touch /usr/local/bin/digger
chmod a+x /usr/local/bin/digger
cat <<EOF > /usr/local/bin/digger
while read p; do
  echo -e "dig +noall +answer \$p"
  dig +noall +answer \$p
  echo ""
done < /var/temp/dns_list.txt
EOF
