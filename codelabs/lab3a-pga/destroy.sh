#!/bin/bash

magenta=`tput setaf 5`
bold=$(tput bold)
reset=`tput sgr0`

source variables.txt

terraform_apply() {
  RESOURCES=(6-storage 5-dns 4-vpn 3-instances 2-router 1-vpc)

  for i in "${RESOURCES[@]}"
  do
    echo ""
    echo "${bold}${magenta}$i ~> destroying...${reset}"
    pushd $i > /dev/null
    terraform init && terraform destroy -auto-approve
    if [ $? -eq 0 ]; then
      echo "${bold}${magenta}$i: destroyed!${reset}"
      popd > /dev/null
    else
      echo "${bold}${magenta}$i: error!${reset}"
      popd > /dev/null
    fi
  done
}

time terraform_apply
