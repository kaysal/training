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
  printf "\n${red}${bold}$1${reset} lab is currently deployed\n"
  read -p "Are you sure you want to remove ${red}${bold}$LAB_DEPLOYED${reset} lab? ( Y/N  y/n  yes/no ): "
  if [[ ! $REPLY =~ ^([yY][eE][sS]|[yY])$ ]]
  then
      return
  fi
  printf "\nRemoving base template for ${red}${bold}$LAB_DEPLOYED ${reset}...\n"
}

tf_destroy() {
  pushd $1 > /dev/null
  printf "\nRunning ${red}${bold}terraform destroy${reset} in directory ${magenta}${bold}$1${reset}...\n"
  terraform destroy -var project_id=$project_id
  popd > /dev/null
}

export TF_WARN_OUTPUT_ERRORS=1
export GOOGLE_PROJECT=$(gcloud config get-value project)
export TF_VAR_project_id=$GOOGLE_PROJECT
export LAB_DEPLOYED=($(cat .tmp))

if [[ -s .tmp ]]; then
  printf "\n${bold}GOOGLE_PROJECT${reset} variable = ${green}${bold}[$GOOGLE_PROJECT]${reset}\n"
  printf "${bold}TF_VAR_project_id${reset} variable = ${green}${bold}[$TF_VAR_project_id]${reset}\n"
  remove $LAB_DEPLOYED
  time tf_destroy "labs/${LAB_DEPLOYED}/"
  > .tmp
else
  printf "\nYou have no labs deployed!\n\n"
fi
