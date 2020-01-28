#!/bin/bash

red=`tput setaf 1`
green=`tput setaf 2`
magenta=`tput setaf 5`
bold=$(tput bold)
reset=`tput sgr0`

source variables.txt

terraform_apply() {
  RESOURCES=( \
  0-iam \
  1-vpc \
  #2-instances \
  #3-router \
  #4-vpn-gw \
  #5-vpn \
  #6-dns \
  8-gke/clust-eu1 \
  #8-gke/clust-us1 \
  #9-td \
  )

  for i in "${RESOURCES[@]}"
  do
    echo ""
    echo "${bold}${magenta}[$i]: deploying...${reset}"
    pushd $i > /dev/null
    terraform fmt && terraform init && terraform apply -auto-approve
    if [ $? -eq 0 ]; then
      echo "${bold}${green}[$i]: deployed!${reset}"
      popd > /dev/null
    else
      echo "${bold}${red}[$i] error!${reset}"
      popd > /dev/null && break
    fi
  done
}

time terraform_apply
