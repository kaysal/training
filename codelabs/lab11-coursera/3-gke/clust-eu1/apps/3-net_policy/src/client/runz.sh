#! /bin/bash

for i in web web2 ifconfig.co
do
  echo "RUN: wget -qO- --timeout=2 http://$i"
  wget -qO- --timeout=2 http://$i
  echo ""
done
