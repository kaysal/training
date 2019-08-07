#! /bin/bash

apt update
apt install -y tcpdump dnsutils

touch /usr/local/bin/scriptz
chmod a+x /usr/local/bin/scriptz
cat <<EOF > /usr/local/bin/scriptz
  dig +noall +answer google.com && echo ""
  dig +noall +answer vm.onprem.lab && echo ""
  dig +noall +answer vm.cloud.lab && echo ""
  dig +noall +answer storage.googleapis.com && echo ""
  dig +noall +answer www.googleapis.com && echo ""
  dig +noall +answer gcr.io
EOF
