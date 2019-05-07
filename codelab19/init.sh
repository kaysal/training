#!/bin/bash

# Copyright 2019 Google LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

red=`tput setaf 1`
green=`tput setaf 2`
yellow=`tput setaf 3`
blue=`tput setaf 4`
magenta=`tput setaf 5`
white_bg=`tput setab 7`
bold=$(tput bold)
reset=`tput sgr0`

init () {
  printf "\nList of Labs\n"
  printf "\n-----------------------\n"

  OLDIFS=$IFS
  IFS=$'\n'
  export LABS=($(cat labs.txt))

  PS3="Select a Lab template number [CRTL+C to exit]: "
  select answer in "${LABS[@]}"; do
    for item in "${LABS[@]}"; do
      if [[ $item == $answer ]]; then
        break 2
      fi
    done
  done

  IFS=$OLDIFS
  LAB=$item

  printf "\nYou selected ${green}${bold}$LAB${reset}\n"
  read -p "Are you sure you want to load ${green}${bold}$LAB${reset} lab? ( Y/N  y/n  yes/no ): "
  if [[ ! $REPLY =~ ^([yY][eE][sS]|[yY])$ ]]
  then
      return
  fi
  printf "\nSetting up the base template for ${green}${bold}$LAB ${reset}...\n"
}

tf_apply() {
  pushd $1 > /dev/null
  printf "\nRunning ${green}${bold}terraform init${reset} in directory ${magenta}${bold}$1${reset}...\n"
  terraform init -input=false
  printf "\nRunning ${green}${bold}terraform plan${reset} in directory ${magenta}${bold}$1${reset}...\n"
  terraform plan -input=false -out tfplan -var project_id=$project_id
  printf "Running ${green}${bold}terraform apply${reset} in directory ${magenta}${bold}$1${reset}...\n"

  terraform apply -input=false tfplan
  if [ $? -eq 0 ]; then
    printf "\n${bold}${green}$2 deployed successfully!${reset}\n"
    rm tfplan
    popd > /dev/null
  else
    printf "\n${bold}${red}Terraform error while deploying $2 Lab !!!${reset}\n"
    printf "\nUse the troubleshooting guide to resolve the error code.${reset}\n"
    rm tfplan
    popd > /dev/null
  fi
}

export TF_WARN_OUTPUT_ERRORS=1
export GOOGLE_PROJECT=$(gcloud config get-value project)
export TF_VAR_project_id=$GOOGLE_PROJECT

printf "\nGOOGLE_PROJECT${reset} variable = ${green}${bold}[$GOOGLE_PROJECT]${reset}\n"
printf "TF_VAR_project_id${reset} variable = ${green}${bold}[$TF_VAR_project_id]${reset}\n"

if [[ -s .tmp ]]; then
  LAB_DEPLOYED=($(cat .tmp))
  printf "\n${green}${bold}$LAB_DEPLOYED${reset} lab is already deployed!\n"
  read -p "Re-deploy ${green}${bold}$LAB_DEPLOYED${reset} lab? ( Y/N  y/n  yes/no ): "
  if [[ ! $REPLY =~ ^([yY][eE][sS]|[yY])$ ]]; then
    printf "To deploy a new lab, you must remove the existing lab\n"
    return
  else
    time tf_apply "labs/${LAB_DEPLOYED}/" "${LAB_DEPLOYED}"
  fi
else
  init
  time tf_apply "labs/${LAB}/" "${LAB}"
  touch .tmp && echo ${LAB} > .tmp
fi
