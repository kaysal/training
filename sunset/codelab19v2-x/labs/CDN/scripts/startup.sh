#! /bin/bash

# Copyright 2019 Google LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

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
