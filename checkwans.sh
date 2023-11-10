#!/bin/bash

PINGCOUNT=2
WAITTIME=2
KEEP=32

in=/root/.wan_interfaces.csv
wemo=/root/.bin/wemo.sh

[ "$1" == "--nolog" ] && unset LOG || LOG=/var/log/reconnect.log
[ "$1" == "--log" ] && [ ! "$2" == "" ] && LOG=$2

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
    [ $LOG ] && echo $today $now $interface down >> $LOG || echo $today $now $interface down 
    if [ "$interface" == "eth4" ]; then
      #$wemo 10.0.0.118 getstate
      [ $LOG ] && ( echo -n $today $now $interface" " ; $wemo 10.0.0.118 off ) >> $LOG || ( echo -n $today $now $interface" " ; $wemo 10.0.0.118 off )
      sleep 3
      [ $LOG ] && ( echo -n $today $now $interface" " ; $wemo 10.0.0.118 on ) >> $LOG || ( echo -n $today $now $interface" " ; $wemo 10.0.0.118 on )
    fi
  else
    [ $LOG ] && echo $today $now $interface up, checking gateway >> $LOG || echo $today $now $interface up, checking gateway
    unset current_gateway
    current_gateway=$(ip route list match default dev $interface | awk '{print $3}')
    # match the gateway to see if the csv needs an update
    if [ "$current_gateway" == "$stored_gateway" ]; then
      [ $LOG ] && echo $today $now $interface gateway valid >> $LOG || echo $today $now $interface gateway valid
      [ $LOG ] && echo $today $now $interface up >> $LOG || echo $today $now $interface up
    else
      [ $LOG ] && echo $today $now $interface not valid, saving new gateway and rechecking >> $LOG || echo $today $now $interface not valid, saving new gateway and rechecking
      netstat -rn | grep -v connectify | grep UG | grep "0.0.0.0" |  awk '{print $8 "," $2}' | sort -u > $in.tmp
    fi
  fi
done < $in
[ -f ${in}.tmp ] && mv ${in}.tmp $in