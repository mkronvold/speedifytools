#!/bin/bash

BYPASS=1

[ "$BYPASS" ] && exit 

DEBUG=

[ "$DEBUG" ] || RUNCMD="/usr/lib/speedifyconf/run.sh"
[ "$DEBUG" ] || WATCHCMD="/usr/share/speedify/speedify_cli"
[ "$DEBUG" ] || WATCHARGS="state"
[ "$DEBUG" ] || TIMEOUT=30
[ "$DEBUG" ] && RUNCMD="/bin/ls"
[ "$DEBUG" ] && WATCHCMD="sleep"
[ "$DEBUG" ] && WATCHARGS="1s"
[ "$DEBUG" ] && TIMEOUT=5
OPTIONS="-v --signal=9"

timeout ${OPTIONS} ${TIMEOUT}s "${WATCHCMD}" "${WATCHARGS}" 2>> /tmp/speedify_watchdog.log 1>> /tmp/speedify_watchdog.log && echo "" || ${RUNCMD} 1>> /tmp/speedify_watchdog.log 2>> /tmp/speedify_watchdog.log
