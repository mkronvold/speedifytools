#!/bin/bash

tmp=./tmp
[ -d $tmp ] || mkdir $tmp
cd $tmp

# grab today's csv
curl -s http://10.0.0.200:81/gwcheck/Today.csv > Today.csv

# put just the header in each file.  Crude.
grep time Today.csv > Today-wan1.csv && cp Today-wan1.csv Today-wan2.csv && cp Today-wan1.csv Today-wan4.csv

# Filter each interface into its own csv.
grep eth1 Today.csv >> Today-wan1.csv
grep eth2 Today.csv >> Today-wan2.csv
grep eth4 Today.csv >> Today-wan4.csv

# create the graph using clip
clip -e ../www/3wan4pings.svg ../3wan4pings.clp

# output
cd ..
ls -oh www/3wan4pings.svg
