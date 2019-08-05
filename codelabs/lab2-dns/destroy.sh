#!/bin/bash

magenta=`tput setaf 5`
bold=$(tput bold)
reset=`tput sgr0`

source *.txt

terraform_apply() {
  RESOURCES=(5-dns 4-vpn 3-router 2-instances 1-vpc)

  for i in "${RESOURCES[@]}"
  do
    echo ""
    echo "${bold}${magenta}[ $i ]${reset}"
    pushd $i > /dev/null
    terraform destroy -auto-approve
    popd > /dev/null
  done
}

time terraform_apply
