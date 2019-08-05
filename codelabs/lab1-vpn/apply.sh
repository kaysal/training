#!/bin/bash

magenta=`tput setaf 5`
bold=$(tput bold)
reset=`tput sgr0`

source *.txt

terraform_apply() {
  RESOURCES=(1-vpc 2-instances 3-router 4-vpn)

  for i in "${RESOURCES[@]}"
  do
    echo ""
    echo "${bold}${magenta}[ $i ]${reset}"
    pushd $i > /dev/null
    terraform init && terraform apply -auto-approve
    popd > /dev/null
  done
}

time terraform_apply
