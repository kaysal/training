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
echo "${bold}GOOGLE_PROJECT${reset} variable set as active project ${yellow}${bold}[$GOOGLE_PROJECT]${reset}"
echo ""

export TF_VAR_project_id=$(gcloud config get-value project)
echo "${bold}TF_VAR_project_id${reset} variable set as active project ${yellow}${bold}[$TF_VAR_project_id]${reset}"
echo ""

while getopts d:l: option
do
  case "${option}" in
    d) FOLDER=$OPTARG;;
    l) LAB=$OPTARG;;
esac
done

tf_apply() {
  cd $FOLDER
  echo "Running ${green}${bold}terraform init${reset} in directory ${magenta}${bold}$FOLDER${reset}..."
  echo ""
  terraform init -input=false
  echo ""
  echo "Running ${green}${bold}terraform plan${reset} in directory ${magenta}${bold}$FOLDER${reset}..."
  echo ""
  terraform plan -input=false -out tfplan -var project_id=$project_id
  echo ""
  echo "Running ${green}${bold}terraform apply${reset} in directory ${magenta}${bold}$FOLDER${reset}..."
  echo ""
  terraform apply -input=false tfplan

  if [ -f tfplan ]; then
    rm tfplan
  fi
}

tf_apply

cd ../..
if [ ! -f lab_deployed.txt ]; then
  touch lab_deployed.txt
fi
echo ${LAB} > lab_deployed.txt
