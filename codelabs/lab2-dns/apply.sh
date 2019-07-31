#!/bin/bash

red=`tput setaf 1`
green=`tput setaf 2`
yellow=`tput setaf 3`
blue=`tput setaf 4`
magenta=`tput setaf 5`
white_bg=`tput setab 7`
bold=$(tput bold)
reset=`tput sgr0`

terraform_apply() {
  RESOURCES=(vpc instances router vpn dns)

  for i in "${RESOURCES[@]}"
  do
    echo ""
    echo "${bold}running terraform apply in${reset} ${bold}${magenta}$i${reset}"
    pushd $i > /dev/null
    terraform init && terraform apply -auto-approve -var-file ../vars.tfvars
    popd > /dev/null
  done
}

time terraform_apply
