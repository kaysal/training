#!/bin/bash

echo "List of Labs"
echo "-----------------------"
IFS=$'\n'
export LABS=($(cat labs.txt))

PS3="Select a Lab template [Press CRTL+C to exit]: "
select answer in "${LABS[@]}"; do
  for item in "${LABS[@]}"; do
    if [[ $item == $answer ]]; then
      break 2
    fi
  done
done
LAB=$item
echo ""
echo "You selected [$LAB]"
sleep 1
echo ""
read -p "Are you sure you want to load [$LAB]? (Y/N | Yes/No):"
if [[ ! $REPLY =~ ^([yY][eE][sS]|[yY])$ ]]
then
    exit 1
fi
echo ""
echo "Configuring the base template for [$LAB]..."
echo ""
sh tf_apply.sh -d "labs/${LAB}/"
