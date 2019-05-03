#! /bin/bash

sudo apt update
sudo apt install -y apache2
cat <<EOF > /var/www/html/index.html
<html><body><h1>Welcome to the CDN demo!</h1>
</body></html>
EOF
ln -s /etc/apache2/mods-available/headers.load /etc/apache2/mods-enabled/headers.load
cat <<EOF > /etc/apache2/sites-available/000-default.conf
<VirtualHost *:80>
        ServerAdmin webmaster@localhost
        DocumentRoot /var/www/html
        ErrorLog ${APACHE_LOG_DIR}/error.log
        CustomLog ${APACHE_LOG_DIR}/access.log combined
        Header set Cache-Control "max-age=86400, public"
</VirtualHost>
EOF
service apache2 restart
