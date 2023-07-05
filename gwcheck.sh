#!/bin/bash


PINGCOUNT=2
WAITTIME=2
TARGET_CHG=gw1.damocles.com
TARGET_DNS=1.1.1.1
TARGET_NACR1=140.177.255.153
TARGET_NACR2=173.230.126.42
LOGDIR=${HOME}/.gwcheck
HTMLDIR=/www/gwcheck
EPOCH=$(date +'%s')
TODAY=$(date +'%Y-%m-%d')
NOW=$(date +'%H:%M:%S')
KEEP=32
HTML=${HTMLDIR}/${TODAY}.html
LOG=${LOGDIR}/${TODAY}.csv

printf "iface \t ipaddr \t gateway \t chg \t dns \t nacr1 \t nacr2\n"
[ -f ${LOG} ] || printf "epoch,date,time,int,iface,ipaddr,gateway,chg,dns,nacr1,nacr2\n" > ${LOG}
# remove all but last KEEP-1 files
(cd ${LOGDIR} && ls -tp | grep -v '/$' | tail -n +${KEEP} | xargs -I {} rm -- {})
# compress all but today
#(cd ${LOGDIR} && ls -tp | grep -v '/$' | tail -n +2 | grep -v .gz | xargs -I {} gzip -- {})
 

readarray -O 1 -t interfaces <<<  $(netstat -rn | grep -v connectify | grep UG | awk '{print $8}' | sort -u)

for i in "${!interfaces[@]}";
do
    interface=${interfaces[$i]}
    ipaddr=$(ip route list match default dev $interface | awk '{print $7}')
    gateway=$(ip route list match default dev $interface | awk '{print $3}')
    ping_chg=$(ping -q -A -w $WAITTIME -c $PINGCOUNT -I $ipaddr $TARGET_CHG | grep round-trip | awk -F/ '{print $4}')
    ping_dns=$(ping -q -A -w $WAITTIME -c $PINGCOUNT -I $ipaddr $TARGET_DNS | grep round-trip | awk -F/ '{print $4}')
    ping_nacr1=$(ping -q -A -w $WAITTIME -c $PINGCOUNT -I $ipaddr $TARGET_NACR1 | grep round-trip | awk -F/ '{print $4}')
    ping_nacr2=$(ping -q -A -w $WAITTIME -c $PINGCOUNT -I $ipaddr $TARGET_NACR2 | grep round-trip | awk -F/ '{print $4}')
    [ "$ping_chg" ] || ping_chg=999
    [ "$ping_dns" ] || ping_dns=999
    [ "$ping_nacr1" ] || ping_nacr1=999
    [ "$ping_nacr2" ] || ping_nacr2=999
    printf "$interface \t $ipaddr\t $gateway\t %2.0f   \t %2.0f   \t %2.0f   \t %2.0f\n" $ping_chg $ping_dns $ping_nacr1 $ping_nacr2
    [ -f ${LOG} ] && printf "$EPOCH,$TODAY,$NOW,$i,$interface,$ipaddr,$gateway,%2.0f,%2.0f,%2.0f,%2.0f\n" $ping_chg $ping_dns $ping_nacr1 $ping_nacr2 >> ${LOG}
done

# make html files
if [ -d $HTMLDIR ]; then
  echo "<HTML><BODY>" > ${HTMLDIR}/index.html
  for i in $(ls -1 ${LOGDIR}); do
    cp ${LOGDIR}/${i} ${HTMLDIR}
    echo "<a href=\"${i}\">${i}</a><br>" >> ${HTMLDIR}/index.html
  done
  echo "</BODY></HTML>" >> ${HTMLDIR}/index.html
fi
# make a copy for Today
cp ${LOG} ${HTMLDIR}/Today.html
