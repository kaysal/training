#! /bin/bash

apt update
apt install -y tcpdump fping dnsutils libxml2-utils apache2-utils

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
