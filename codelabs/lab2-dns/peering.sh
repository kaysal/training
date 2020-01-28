#!/bin/bash

gcloud beta compute networks peerings create cloud1-to-cloud2 \
  --network lab2-cloud1-vpc \
  --peer-network lab2-cloud2-vpc \
  --peer-project kayode-salawu \
  --import-custom-routes \
  --export-custom-routes

gcloud beta compute networks peerings create cloud1-to-cloud3 \
  --network lab2-cloud1-vpc \
  --peer-network lab2-cloud3-vpc \
  --peer-project kayode-salawu \
  --import-custom-routes \
  --export-custom-routes

gcloud beta compute networks peerings create cloud2-to-cloud1 \
  --network lab2-cloud2-vpc \
  --peer-network lab2-cloud1-vpc \
  --peer-project kayode-salawu \
  --import-custom-routes \
  --export-custom-routes

gcloud beta compute networks peerings create cloud3-to-cloud1 \
  --network lab2-cloud3-vpc \
  --peer-network lab2-cloud1-vpc \
  --peer-project kayode-salawu \
  --import-custom-routes \
  --export-custom-routes
