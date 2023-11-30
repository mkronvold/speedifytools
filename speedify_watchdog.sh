#!/bin/bash

BYPASS=

[ "$BYPASS" ] && exit 

LOG=/tmp/speedify_watchdog.log
DEBUG=

[ "$DEBUG" ] || RUNCMD="/usr/lib/speedifyconf/run.sh restart"
[ "$DEBUG" ] || WATCHCMD="/usr/share/speedify/speedify_cli"
[ "$DEBUG" ] || WATCHARGS="state"
[ "$DEBUG" ] || TIMEOUT=30
[ "$DEBUG" ] && RUNCMD="/bin/ls"
[ "$DEBUG" ] && WATCHCMD="sleep"
[ "$DEBUG" ] && WATCHARGS="1s"
[ "$DEBUG" ] && TIMEOUT=5
OPTIONS="-v --signal=9"

echo -n "$(date +'%Y-%m-%d_%H:%M:%S') " >> $LOG

timeout ${OPTIONS} ${TIMEOUT}s "${WATCHCMD}" "${WATCHARGS}" 2>> $LOG 1>> $LOG && echo "" || ${RUNCMD} 1>> $LOG 2>> $LOG
