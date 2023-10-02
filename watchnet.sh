#!/bin/bash

while [ 1 ]; 
do
  ./checknet.sh || /usr/share/speedify/speedify_cli connect
  sleep 30
done
