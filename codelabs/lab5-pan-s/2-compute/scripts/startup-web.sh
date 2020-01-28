#! /bin/bash
apt-get update
apt-get install -y apache2 php
cd /var/www/html
rm index.html -f
rm index.php -f
META_REGION_STRING=$(curl "http://metadata.google.internal/computeMetadata/v1/instance/zone" -H "Metadata-Flavor: Google")
REGION=`echo "$META_REGION_STRING" | awk -F/ '{print $4}'`

mkdir app80
pushd app80
wget https://storage.googleapis.com/salawu-gcs/gcp/images/favicons/ilb/favicon.ico
wget https://storage.googleapis.com/salawu-gcs/gcp/instances/index.php
IMAGE=https://storage.googleapis.com/salawu-gcs/gcp/images/app80.png
sed -i "s|region-here|$REGION|" index.php
sed -i "s|image-here|$IMAGE|" index.php
popd

mkdir app8080
pushd app8080
wget https://storage.googleapis.com/salawu-gcs/gcp/images/favicons/cassette/favicon.ico
wget https://storage.googleapis.com/salawu-gcs/gcp/instances/index.php
IMAGE=https://storage.googleapis.com/salawu-gcs/gcp/images/app8080.png
sed -i "s|region-here|$REGION|" index.php
sed -i "s|image-here|$IMAGE|" index.php
popd

echo 'Listen 8080' >> /etc/apache2/ports.conf

#cat <<EOF > /etc/apache2/sites-enabled/000-default.conf
# Application at port 80
#<VirtualHost *:80>
#        ServerAdmin webmaster@localhost
#        DocumentRoot /var/www/html/app80/
#        ErrorLog ${APACHE_LOG_DIR}/error.log
#        CustomLog ${APACHE_LOG_DIR}/access.log combined
#</VirtualHost>
# Application at port 8080
#<VirtualHost *:8080>
#        ServerAdmin webmaster@localhost
#        DocumentRoot /var/www/html/app8080/
#        ErrorLog ${APACHE_LOG_DIR}/error.log
#        CustomLog ${APACHE_LOG_DIR}/access.log combined
#</VirtualHost>
#EOF

service apache2 restart

cd
# To install the Stackdriver monitoring agent:
curl -sSO https://dl.google.com/cloudagents/install-monitoring-agent.sh
bash install-monitoring-agent.sh
# To install the Stackdriver logging agent:
curl -sSO https://dl.google.com/cloudagents/install-logging-agent.sh
bash install-logging-agent.sh
