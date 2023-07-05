#!/bin/sh

in=$1

#[ -f ${in} ] || echo "Usage: $0 {input csv file}"; exit 1

#date,time,int,iface,ipaddr,gateway,chg,dns,nacr1,nacr2

while IFS=, read -r date time int iface ipaddr gateway chg dns nacr1 nacr2
do
  if [ $date = "date" ]; then
    echo "epoch,date,time,int,iface,ipaddr,gateway,chg,dns,nacr1,nacr2"
  else
    epoch=$(date --date "$date $time" +'%s')
    echo $epoch,$date,$time,$int,$iface,$ipaddr,$gateway,$chg,$dns,$nacr1,$nacr2
  fi
done < $in
