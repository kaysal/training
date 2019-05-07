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

remove () {
  printf "\n${red}${bold}$2${reset} lab is currently deployed\n"
  read -p "Are you sure you want to remove ${red}${bold}$2${reset} lab? ( Y/N  y/n  yes/no ): "
  if [[ ! $REPLY =~ ^([yY][eE][sS]|[yY])$ ]]; then
      return
  else
    printf "\nRemoving base template for ${red}${bold}$2 ${reset}...\n"
    tf_destroy $1 $2
  fi
}

tf_destroy() {
  pushd $1 > /dev/null
  printf "\nRunning ${red}${bold}terraform destroy${reset} in directory ${magenta}${bold}$1${reset}...\n"

  terraform destroy -var project_id=$project_id
  if [ $? -eq 0 ]; then
    printf "\n${bold}${green}$2 removed successfully!${reset}\n"
    popd > /dev/null
    rm .tmp
  else
    printf "\n${bold}${red}Terraform error while removing $2 Lab !!!${reset}\n"
    printf "\nUse the troubleshooting guide to resolve the error code.${reset}\n"
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
  time remove "labs/${LAB_DEPLOYED}/" ${LAB_DEPLOYED}
  printf "\ndone!\n"
else
  printf "\nYou have no labs deployed!\n\n"
fi
