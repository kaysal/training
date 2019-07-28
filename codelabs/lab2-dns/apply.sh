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
    echo "Running ${bold}${magenta}terraform apply${reset} --> ${bold}${blue}$i${reset}"
    pushd $i > /dev/null
    terraform init
    terraform apply \
      -var-file ../vars.tfvars \
      -auto-approve
    popd > /dev/null
  done
}

time terraform_apply
