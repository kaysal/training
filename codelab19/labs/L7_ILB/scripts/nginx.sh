#! /bin/bash

sudo apt update
sudo apt install -y nginx
mkdir /var/www/html/nginx/
cat <<EOF > /var/www/html/nginx/index.html
<html><body><h1>This is nginx</h1>
</body></html>
EOF
