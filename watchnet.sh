#!/bin/bash

while [ 1 ]; 
do
  ./checknet.sh -q || /usr/share/speedify/speedify_cli connect
  sleep 30
done
