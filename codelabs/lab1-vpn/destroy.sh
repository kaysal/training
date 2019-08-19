#!/bin/bash

red=`tput setaf 1`
green=`tput setaf 2`
magenta=`tput setaf 5`
bold=$(tput bold)
reset=`tput sgr0`

source variables.txt

terraform_destroy() {
  RESOURCES=(4-vpn 3-router 2-instances 1-vpc)

  for i in "${RESOURCES[@]}"
  do
    echo ""
    echo "${bold}${magenta}[$i]: destroying...${reset}"
    pushd $i > /dev/null
    terraform init && terraform destroy -auto-approve
    if [ $? -eq 0 ]; then
      echo "${bold}${green}[$i]: destroyed!${reset}"
      popd > /dev/null
    else
      echo "${bold}${red}[$i]: error!${reset}"
      popd > /dev/null
    fi
  done
}

time terraform_destroy
