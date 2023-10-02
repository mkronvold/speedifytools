#!/bin/bash

datestamp=$(date +'%Y-%m-%d_%H:%M:%S')
wget -q --tries=3 --timeout=3 --spider http://bing.com
if [[ $? -eq 0 ]]; then
  echo "[${datestamp}] Online"
  exit 0
else
  echo "[${datestamp}] Offline"
  exit 1
fi
