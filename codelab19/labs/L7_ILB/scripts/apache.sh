#! /bin/bash

sudo apt update
sudo apt install -y apache2
cat <<EOF > /var/www/html/index.html
<html><body><h1>This is Apache</h1>
</body></html>
EOF
