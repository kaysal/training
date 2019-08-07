#!/bin/bash

magenta=`tput setaf 5`
bold=$(tput bold)
reset=`tput sgr0`

source variables.txt

terraform_apply() {
  RESOURCES=(1-vpc 2-router 3-instances 4-vpn 5-dns 6-storage)

  for i in "${RESOURCES[@]}"
  do
    echo ""
    echo "${bold}${magenta}$i ~> deploying...${reset}"
    pushd $i > /dev/null
    terraform init && terraform apply -auto-approve
    if [ $? -eq 0 ]; then
      echo "${bold}${magenta}$i: deployed!${reset}"
      popd > /dev/null
    else
      echo "${bold}${magenta}$i: error!${reset}"
      popd > /dev/null && break
    fi
  done
}

time terraform_apply
