#! /bin/bash

mv /usr/share/nginx/html/index.html /usr/share/nginx/html/index.html.bak
touch /usr/share/nginx/html/index.html
cat <<EOF > /usr/share/nginx/html/index.html

$NODE_NAME
$HOST_IP

$NAME
$POD_IP

namespace:   $NAMESPACE
svc_account: $SERVICE_ACCOUNT_NAME
EOF
