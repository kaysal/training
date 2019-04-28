#!/bin/bash

red=`tput setaf 1`
green=`tput setaf 2`
yellow=`tput setaf 3`
blue=`tput setaf 4`
magenta=`tput setaf 5`
white_bg=`tput setab 7`
bold=$(tput bold)
reset=`tput sgr0`

export LAB_DEPLOYED=($(cat lab_deployed.txt))
echo ""
echo "${red}${bold}$LAB_DEPLOYED${reset} lab is currently deployed"
echo ""
read -p "Are you sure you want to remove ${red}${bold}$LAB_DEPLOYED${reset} lab? (Y/N | Yes/No):"
if [[ ! $REPLY =~ ^([yY][eE][sS]|[yY])$ ]]
then
    exit 1
fi
echo ""
echo "Removing base template for ${red}${bold}$LAB_DEPLOYED ${reset}..."
echo ""
time sh tf_destroy.sh -d "labs/${LAB_DEPLOYED}/" -l ${LAB_DEPLOYED}

if [ -f lab_deployed.txt ]; then
  #sed -i "s|$LAB_DEPLOYED||" labs_deployed.txt
  rm lab_deployed.txt
fi
