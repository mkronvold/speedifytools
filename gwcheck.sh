#!/bin/bash

PINGCOUNT=2
WAITTIME=2
KEEP=32

TARGET_CHG=gw1.damocles.com
TARGET_DNS=1.1.1.1
TARGET_NACR1=140.177.255.153
TARGET_NACR2=173.230.126.42

# Establish some timestamps
today=$(date +'%Y-%m-%d')
now=$(date +'%H:%M:%S')
epoch=$(date +'%s')

logdir=${HOME}/.gwcheck
log=${logdir}/${today}.log
csvdir=${HOME}/.gwcheck
csv=${csvdir}/${today}.csv
htmldir=/www/gwcheck
html=${htmldir}/${today}.csv

### Which ping are we using?
[ $(file $(which ping) | grep -c busybox) == 1 ] && pinger=busybox || pinger=iputils


### set up output flags, directories and files and build initial headers
#
while [[ $# -gt 0 ]] && [[ "$1" == "-"* ]] ;
do
    opt=${1}
    case "${opt}" in
        "--" )
          break 2;;
        "--csv" )
          out=csv
          outdir=$csvdir
          outfile=$csv
          [ -f $outfile ] || printf "epoch,date,time,int,iface,ipaddr,gateway,chg,dns,nacr1,nacr2\n" > $outfile
          ;;
        "--html" )
          out=html
          outdir=$htmldir
          outfile=$html
          [ -f $outfile ] || printf "epoch,date,time,int,iface,ipaddr,gateway,chg,dns,nacr1,nacr2\n" > $outfile
          ;;
        "--log" )
          out=log
          outdir=$logdir
          outfile=$log
          [ -f $outfile ] || printf "date,time,int,iface,ipaddr,gateway,chg,dns,nacr1,nacr2\n" > $outfile
          ;;
        "--help" )
            echo "Usage: $0 TODO"
            exit 1
            ;;
        "-h" )
            echo "Usage: $0 TODO"
            exit 1
            ;;
        "--text" )
          out=text
          printf "iface \t ipaddr \t gateway \t chg \t dns \t nacr1 \t nacr2\n"
          ;;
        *)
          # if we fall through and no out was selected, we just log to console
          out=text
          printf "iface \t ipaddr \t gateway \t chg \t dns \t nacr1 \t nacr2\n"
        ;;
    esac
    shift
done

#case "$out" in
#  "log" )
#    ;;
#  "csv" )
#    ;;
#  "html" )
#    ;;
#  "text" )
#    ;;
#  *)
#    ;;
#esac

# remove all but last KEEP-1 files
# don't process if not creating any output
[[ $out == "text" ]] || (cd ${outdir} && ls -tp | grep -v '/$' | tail -n +${KEEP} | xargs -I {} rm -- {})

# read the interfaces into an array
readarray -O 1 -t interfaces <<<  $(netstat -rn | grep -v connectify | grep UG | awk '{print $8}' | sort -u)

# gather ip and gateway info for each interface and ping from each interface to each target
for i in "${!interfaces[@]}";
do
    interface=${interfaces[$i]}
    ipaddr=$(ip route list match default dev $interface | awk '{print $7}')
    gateway=$(ip route list match default dev $interface | awk '{print $3}')
	if [ $pinger == busybox ]; then 
		ping_chg=$(ping -q -A -w $WAITTIME -c $PINGCOUNT -I $ipaddr $TARGET_CHG | grep round-trip | awk -F/ '{print $4}')
		ping_dns=$(ping -q -A -w $WAITTIME -c $PINGCOUNT -I $ipaddr $TARGET_DNS | grep round-trip | awk -F/ '{print $4}')
		ping_nacr1=$(ping -q -A -w $WAITTIME -c $PINGCOUNT -I $ipaddr $TARGET_NACR1 | grep round-trip | awk -F/ '{print $4}')
		ping_nacr2=$(ping -q -A -w $WAITTIME -c $PINGCOUNT -I $ipaddr $TARGET_NACR2 | grep round-trip | awk -F/ '{print $4}')
	else
		ping_chg=$(ping -q -A -w $WAITTIME -c $PINGCOUNT -I $ipaddr $TARGET_CHG | grep rtt | awk -F/ '{print $5}')
		ping_dns=$(ping -q -A -w $WAITTIME -c $PINGCOUNT -I $ipaddr $TARGET_DNS | grep rtt | awk -F/ '{print $5}')
		ping_nacr1=$(ping -q -A -w $WAITTIME -c $PINGCOUNT -I $ipaddr $TARGET_NACR1 | grep rtt | awk -F/ '{print $5}')
		ping_nacr2=$(ping -q -A -w $WAITTIME -c $PINGCOUNT -I $ipaddr $TARGET_NACR2 | grep rtt | awk -F/ '{print $5}')
	fi
    [ "$ping_chg" ] || ping_chg=999
    [ "$ping_dns" ] || ping_dns=999
    [ "$ping_nacr1" ] || ping_nacr1=999
    [ "$ping_nacr2" ] || ping_nacr2=999
    case "$out" in
      "log" )
        printf "$TODAY,$NOW,$i,$interface,$ipaddr,$gateway,%2.0f,%2.0f,%2.0f,%2.0f\n" $ping_chg $ping_dns $ping_nacr1 $ping_nacr2 >> $outfile
        ;;
      "csv" )
        printf "$EPOCH,$TODAY,$NOW,$i,$interface,$ipaddr,$gateway,%2.0f,%2.0f,%2.0f,%2.0f\n" $ping_chg $ping_dns $ping_nacr1 $ping_nacr2 >> $outfile
        ;;
      "html" )
        printf "$EPOCH,$TODAY,$NOW,$i,$interface,$ipaddr,$gateway,%2.0f,%2.0f,%2.0f,%2.0f\n" $ping_chg $ping_dns $ping_nacr1 $ping_nacr2 >> $outfile
        ;;
      *)
        # includes text
        printf "$interface \t $ipaddr\t $gateway\t %2.0f   \t %2.0f   \t %2.0f   \t %2.0f\n" $ping_chg $ping_dns $ping_nacr1 $ping_nacr2
        ;;
    esac
done

if [[ $out == "html" ]]; then
  # make html files

  # make a copy of the latest for Today
  cp $outfile ${outdir}/Today.csv

  # build the index
  index=${outdir}/index.html
  echo "<HTML><BODY>" > $index
  for i in $(ls -1 ${outdir}/*.csv); do
    ref=$(basename ${i})
    echo "<a href=\"/gwcheck/${ref}\">${ref}</a><br>" >> $index
  done
  echo "</BODY></HTML>" >> $index
fi
