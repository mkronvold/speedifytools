#!/bin/bash

### show all adapters that speedify is showing down
DISCONNECTED=$(/usr/share/speedify/speedify_cli show adapters | jsonfilter -e '@[@.state="disconnected"].name')

### exit if there aren't any
[ $DISCONNECTED ] || exit 1

### only work on the first one
FIRSTDOWN=$(echo $DISCONNECTED | head -1)

### find the if name for the first down iface
FLOP=$(uci show network | grep $DISCONNECTED | grep device | awk -F. '{print $2}')

### flop it
ifdown $FLOP
ifup $FLOP
