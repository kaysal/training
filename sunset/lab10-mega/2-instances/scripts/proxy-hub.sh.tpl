#! /bin/bash

apt update
apt install -y tcpdump dnsutils fping dnsutils libxml2-utils apache2-utils

sh -c "echo 1 > /proc/sys/net/ipv4/ip_forward"

iptables -A FORWARD -i eth0 -o eth1 -j ACCEPT
iptables -A FORWARD -i eth1 -o eth0 -j ACCEPT

iptables -t nat -A POSTROUTING -o eth0 -d ${ONPREM_UNBOUND_IP} -j SNAT --to-source ${HUB_PROXY_IP}
iptables -A PREROUTING -t nat -i eth0 -d ${HUB_PROXY_IP} -p udp --dport 53 -j DNAT --to ${ONPREM_UNBOUND_IP}
iptables -A PREROUTING -t nat -i eth0 -d ${HUB_PROXY_IP} -p tcp --dport 53 -j DNAT --to ${ONPREM_UNBOUND_IP}

ifconfig eth1 ${HUB_PROXY_IPX} netmask 255.255.255.255 broadcast ${HUB_PROXY_IPX} mtu 1430
echo "1 rt1" | sudo tee -a /etc/iproute2/rt_tables
ip route add ${HUB_PROXY_IPX_DEFAULT_GW} src ${HUB_PROXY_IPX} dev eth1 table rt1
ip route add default via ${HUB_PROXY_IPX_DEFAULT_GW} dev eth1 table rt1
ip rule add from ${HUB_PROXY_IPX}/32 table rt1
ip rule add to ${HUB_PROXY_IPX}/32 table rt1
ip rule add to ${SVC_EU_SUBNET} table rt1
ip rule add to ${SVC_ASIA_SUBNET} table rt1
ip rule add to ${SVC_US_SUBNET} table rt1

# file containing dns names to ping

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
vm.eu.svc.lab
vm.asia.svc.lab
vm.us.svc.lab
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
