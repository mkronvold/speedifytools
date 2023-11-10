#!/bin/bash

PINGCOUNT=2
WAITTIME=2
KEEP=32

TARGET_CHG=gw1.damocles.com
TARGET_DNS=1.1.1.1
TARGET_NACR1=140.177.157.72
TARGET_NACR2=173.230.126.7

in=/root/.wan_interfaces.csv
wemo=/root/.bin/wemo.sh


# Establish some timestamps
today=$(date +'%Y-%m-%d')
now=$(date +'%H:%M:%S')

# read the interfaces into an array
# parse gateway for each interface
# verify each is up
# verify current gateway against saved gateway

#date,time,int,iface,ipaddr,gateway,chg,dns,nacr1,nacr2

while IFS=, read -r interface stored_gateway
do
  unset current_ipaddr
  current_ipaddr=$(ip route list match default dev $interface | awk '{print $7}')
  if [ "${current_ipaddr}" == "" ]; then
    echo $today $now $interface down
    #$wemo 10.0.0.118 getstate
    $wemo 10.0.0.118 off
    sleep 3
    $wemo 10.0.0.118 on
  else
    echo $today $now $interface up, checking gateway
    unset current_gateway
    current_gateway=$(ip route list match default dev $interface | awk '{print $3}')
    # match the gateway to see if the csv needs an update
    if [ "$current_gateway" == "$stored_gateway" ]; then
      echo $today $now $interface gateway valid
      echo $today $now $interface up
    else
      echo $today $now $interface not valid, saving new gateway and rechecking
      netstat -rn | grep -v connectify | grep UG | grep "0.0.0.0" |  awk '{print $8 "," $2}' | sort -u > $in.tmp
    fi
  fi
done < $in
[ -f ${in}.tmp ] && (echo $today $now ; mv -v ${in}.tmp $in)