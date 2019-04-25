#!/bin/bash

red=`tput setaf 1`
green=`tput setaf 2`
yellow=`tput setaf 3`
blue=`tput setaf 4`
magenta=`tput setaf 5`
white_bg=`tput setab 7`
bold=$(tput bold)
reset=`tput sgr0`

export TF_WARN_OUTPUT_ERRORS=1
export GOOGLE_PROJECT=$(gcloud config get-value project)
echo "${blue}${bold}GOOGLE_PROJECT${reset} variable set as active project ${blue}${bold}[$GOOGLE_PROJECT]${reset}"
echo ""

export TF_VAR_project_id=$(gcloud config get-value project)
echo "${blue}${bold}TF_VAR_project_id${reset} variable set as active project ${blue}${bold}[$TF_VAR_project_id]${reset}"
echo ""

while getopts d:h: option
do
  case "${option}" in
    d) FOLDER=$OPTARG;;
    h) HELP=$OPTARG;;
esac
done

tf_destroy() {
  cd $FOLDER
  echo "Running ${red}${bold}terraform destroy${reset} in directory ${magenta}${bold}$FOLDER${reset}..."
  echo ""
  terraform destroy -var project_id=$project_id
}

tf_destroy
