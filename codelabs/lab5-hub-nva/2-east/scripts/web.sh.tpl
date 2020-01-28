#! /bin/bash

apt-get update
apt-get install -y apache2 apache2-utils

vm_hostname="$(curl -H "Metadata-Flavor:Google" \
http://169.254.169.254/computeMetadata/v1/instance/name)"
echo "$vm_hostname" | tee /var/www/html/index.html
echo 'Listen 8080' >> /etc/apache2/ports.conf
systemctl restart apache2
