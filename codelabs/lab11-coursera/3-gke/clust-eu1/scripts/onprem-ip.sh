#!/bin/bash

echo {\"ip\":\""`wget -qO- http://ipecho.net/plain | xargs echo`"\"}
