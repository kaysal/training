#!/bin/bash

red=`tput setaf 1`
green=`tput setaf 2`
magenta=`tput setaf 5`
bold=$(tput bold)
reset=`tput sgr0`

source variables.txt
export TF_WARN_OUTPUT_ERRORS=1
export GOOGLE_PROJECT=$(gcloud config get-value project)

terraform_apply() {
  local PROJECTS=(net-top-viz-demo)
  for i in "${PROJECTS[@]}"
  do
    local NETWORKS=(default net-peering)
    pushd $i > /dev/null
    for j in "${NETWORKS[@]}"
    do
      pushd $j > /dev/null
      echo ""
      echo "${bold}${magenta} | $i > $j : deploying...${reset}"
      terraform fmt && terraform init && terraform apply -auto-approve
      if [ $? -eq 0 ]; then
        echo "${bold}${green}[$i]: deployed!${reset}"
        popd > /dev/null
      else
        echo "${bold}${red} | $i > $j : error!${reset}"
        popd > /dev/null && break
      fi
    done
    popd > /dev/null
  done
}

time terraform_apply
