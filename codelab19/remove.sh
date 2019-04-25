#!/bin/bash

red=`tput setaf 1`
green=`tput setaf 2`
yellow=`tput setaf 3`
blue=`tput setaf 4`
magenta=`tput setaf 5`
white_bg=`tput setab 7`
bold=$(tput bold)
reset=`tput sgr0`

echo "List of Labs"
echo "-----------------------"
IFS=$'\n'
export LABS=($(cat labs.txt))

PS3="Select a Lab template number [Press CRTL+C to exit]: "
select answer in "${LABS[@]}"; do
  for item in "${LABS[@]}"; do
    if [[ $item == $answer ]]; then
      break 2
    fi
  done
done
LAB=$item
echo ""
echo "You selected ${red}${bold}$LAB${reset}"
echo ""
read -p "Are you sure you want to remove ${red}${bold}$LAB${reset}? (Y/N | Yes/No):"
if [[ ! $REPLY =~ ^([yY][eE][sS]|[yY])$ ]]
then
    exit 1
fi
echo ""
echo "Removing base template for ${red}${bold}$LAB ${reset}..."
echo ""
sh tf_destroy.sh -d "labs/${LAB}/"
