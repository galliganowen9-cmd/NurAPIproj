#!/bin/bash
#Its intended to watch the tshark console during this test
count=0
count2=0
{
printf '\xa5\x03\x00\x00\x00\x59\x01\xd1\xf1' #ping
sleep 0.5
printf '\xa5\x06\x00\x00\x00\x5c\x39\x00\x00\x0a\x14\xfa' #repeated scan
sleep 10  
} | nc -q 1 172.168.253.150 4333
