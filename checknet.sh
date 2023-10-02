#!/bin/bash

[ "$1" == "-q" ] && QUIET=1 || QUIET=0

datestamp=$(date +'%Y-%m-%d_%H:%M:%S')
wget -q --tries=3 --timeout=3 --spider http://bing.com
if [[ $? -eq 0 ]]; then
  [ $QUIET ] || echo "[${datestamp}] Online"
  exit 0
else
  echo "[${datestamp}] Offline"
  exit 1
fi
