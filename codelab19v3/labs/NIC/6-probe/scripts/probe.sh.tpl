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
i=0
while [ \$i -lt 8 ]; do
  ab -n 20 -c 5 http://${TARGET1}/ > /dev/null 2>&1
  ab -n 20 -c 5 http://${TARGET2}/ > /dev/null 2>&1
  let i=i+1
  sleep 1
done
EOF

echo "* * * * * /usr/local/bin/probez 2>&1 > /dev/null" > /tmp/crontab.txt
crontab /tmp/crontab.txt
