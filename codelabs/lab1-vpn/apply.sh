#!/bin/bash

magenta=`tput setaf 5`
bold=$(tput bold)
reset=`tput sgr0`

source variables.txt

terraform_apply() {
  RESOURCES=(1-vpc 2-instances 3-router 4-vpn)

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
