#!/bin/bash

red=`tput setaf 1`
green=`tput setaf 2`
yellow=`tput setaf 3`
blue=`tput setaf 4`
magenta=`tput setaf 5`
white_bg=`tput setab 7`
bold=$(tput bold)
reset=`tput sgr0`

RESOURCES=(dns vpn router instances vpc)

terraform_destroy() {
  for i in "${RESOURCES[@]}"

  do
    echo ""
    echo "Running ${bold}${magenta}terraform destroy${reset} --> ${bold}${blue}$i${reset}"
    pushd $i > /dev/null
    terraform destroy \
      -var-file ../vars.tfvars \
      -auto-approve
    popd > /dev/null
  done
}

time terraform_destroy
