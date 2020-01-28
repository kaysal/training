#! /bin/bash

apt-get update
apt-get install apache2 -y
vm_hostname="$(curl -H "Metadata-Flavor:Google" \
http://169.254.169.254/computeMetadata/v1/instance/name)"
echo "$vm_hostname" | tee /var/www/html/index.html
systemctl restart apache2

# probe script

touch /usr/local/bin/probez
chmod a+x /usr/local/bin/probez
cat <<EOF > /usr/local/bin/probez
i=0
while [ \$i -lt 8 ]; do
  ab -n 4 -c 2 http://${TARGET}/ > /dev/null 2>&1
  let i=i+1
  sleep 1
done
EOF

echo "*/3 * * * * /usr/local/bin/probez 2>&1 > /dev/null" > /tmp/crontab.txt
crontab /tmp/crontab.txt
