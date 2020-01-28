#! /bin/bash

apt update
apt install -y tcpdump fping dnsutils libxml2-utils

touch /usr/local/bin/digger
chmod a+x /usr/local/bin/digger
cat <<EOF > /usr/local/bin/digger
  echo -e "\ndig +noall +answer google.com"
  dig +noall +answer google.com

  echo -e "\ndig +noall +answer vma.onprem.lab"
  dig +noall +answer vma.onprem.lab

  echo -e "\ndig +noall +answer vmb.onprem.lab"
  dig +noall +answer vmb.onprem.lab

  echo -e "\ndig +noall +answer vma.spoke1.lab"
  dig +noall +answer vma.spoke1.lab

  echo -e "\ndig +noall +answer vmb.spoke1.lab"
  dig +noall +answer vmb.spoke1.lab

  echo -e "\ndig +noall +answer vma.spoke2.lab"
  dig +noall +answer vma.spoke2.lab

  echo -e "\ndig +noall +answer vmb.spoke2.lab"
  dig +noall +answer vmb.spoke2.lab

  echo -e "\ndig +noall +answer storage.googleapis.com"
  dig +noall +answer storage.googleapis.com

  echo -e "\ndig +noall +answer www.googleapis.com"
  dig +noall +answer www.googleapis.com

  echo -e "\ndig +noall +answer compute.googleapis.com"
  dig +noall +answer compute.googleapis.com

  echo -e "\ndig +noall +answer gcr.io"
  dig +noall +answer gcr.io
EOF

mkdir /var/temp
touch /var/temp/dns_names.txt
cat <<EOF > /var/temp/dns_names.txt
  vma.onprem.lab
  vmb.onprem.lab
  vma.spoke1.lab
  vmb.spoke1.lab
  vma.spoke2.lab
  vmb.spoke2.lab
EOF

touch /usr/local/bin/pinger
chmod a+x /usr/local/bin/pinger
cat <<EOF > /usr/local/bin/pinger
  fping -A -f /var/temp/dns_names.txt
EOF
