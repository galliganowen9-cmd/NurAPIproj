#!/bin/bash
#This is to extract data points from readable data files to make plotting
#easy
G="/home/samalab/NurAPI/data"
sudo awk -F '[[:space:]]*:[[:space:]]*' \
'$1 == "GPS x" && ($2+0) != 0 { print $2 }' $G/djiwrite.txt > $G/organizeddata/gps_x_values.txt

sudo awk -F '[[:space:]]*:[[:space:]]*' \
'$1 == "GPS y" && ($2+0) != 0 { print $2 }' $G/djiwrite.txt > $G/organizeddata/gps_y_values.txt

sudo awk -F '[[:space:]]*:[[:space:]]*' \
'$1 == "[UTC]" && ($2+0) != 0 { print $2 }' $G/djiwrite.txt > $G/organizeddata/drone_utc_values.txt

sudo gawk -f /home/samalab/NurAPI/filter/Nurfil.awk /home/samalab/NurAPI/data/orgdata.txt



