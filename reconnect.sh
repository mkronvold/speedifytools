#!/bin/bash

### show all adapters that speedify is showing down
DISCONNECTED=$(/usr/share/speedify/speedify_cli show adapters | jsonfilter -e '@[@.state="disconnected"].name')

TIMESTAMP="$(date +'%Y-%m-%d %H:%M:%S')"

### exit if there aren't any
[ $DISCONNECTED ] && echo "$TIMESTAMP $DISCONNECT offline" >> /var/log/reconnect.log || exit 1

### only work on the first one
FIRSTDOWN=$(echo $DISCONNECTED | head -1)

### find the if name for the first down iface
FLOP=$(uci show network | grep $DISCONNECTED | grep device | awk -F. '{print $2}')
echo "$TIMESTAMP Reconnecting $FLOP" >> /var/log/reconnect.log

### flop it
ifdown $FLOP
ifup $FLOP
