#! /bin/bash

apt update
apt install -y tcpdump dnsutils

touch /usr/local/bin/scriptz
chmod a+x /usr/local/bin/scriptz
cat <<EOF > /usr/local/bin/scriptz
  echo -e "\ndig +noall +answer google.com"
  dig +noall +answer google.com

  echo -e "\ndig +noall +answer vm.onprem.lab"
  dig +noall +answer vm.onprem.lab

  echo -e "\ndig +noall +answer vm.cloud.lab"
  dig +noall +answer vm.cloud.lab

  echo -e "\ndig +noall +answer storage.googleapis.com"
  dig +noall +answer storage.googleapis.com

  echo -e "\ndig +noall +answer www.googleapis.com"
  dig +noall +answer www.googleapis.com

  echo -e "\ndig +noall +answer compute.googleapis.com"
  dig +noall +answer compute.googleapis.com

  echo -e "\ndig +noall +answer gcr.io"
  dig +noall +answer gcr.io
EOF
