#! /bin/bash

apt update
apt install -y tcpdump fping apache2 apache2-utils dnsutils

vm_hostname="$(curl -H "Metadata-Flavor:Google" \
http://169.254.169.254/computeMetadata/v1/instance/name)"
echo "$vm_hostname" | \
tee /var/www/html/index.html
systemctl restart apache2

# probe script

touch /usr/local/bin/probez
chmod a+x /usr/local/bin/probez
cat <<EOF > /usr/local/bin/probez
while true
do
  ab -n 500 -c 20 -s 2 http://${TARGET1}/
  ab -n 500 -c 20 -s 2 http://${TARGET2}/
  echo ""
done
EOF
