#! /bin/bash

apt-get update
apt-get install -y apache2 php
cd /var/www/html
rm index.html -f
rm index.php -f
wget https://storage.googleapis.com/salawu-gcs/gcp/images/favicons/prod/favicon.ico
wget https://storage.googleapis.com/salawu-gcs/gcp/instances/index.php
META_REGION_STRING=$(curl "http://metadata.google.internal/computeMetadata/v1/instance/zone" -H "Metadata-Flavor: Google")
REGION=`echo "$META_REGION_STRING" | awk -F/ '{print $4}'`
IMAGE=https://storage.googleapis.com/salawu-gcs/gcp/images/prod_blue_app.png
sed -i "s|region-here|$REGION|" index.php
sed -i "s|image-here|$IMAGE|" index.php
