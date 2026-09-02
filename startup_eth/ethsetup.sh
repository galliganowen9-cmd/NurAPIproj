#!/bin/bash
#Script sets up eth0 to listen for the static IP of the RFID reader
sudo ip addr flush dev eth0
sudo ip link set eth0 up
sudo ip addr add 172.168.253.1/24 dev eth0
