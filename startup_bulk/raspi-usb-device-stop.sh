#!/bin/bash

#service raspi-usb-device pi4br0,usb0 stop

/bin/killall startup_bulk
sleep 1

/sbin/ifconfig pi4br0 down
/sbin/brctl delif pi4br0 usb0
/sbin/brctl delbr pi4br0

/sbin/ifconfig usb0 down

# cd /sys/kernel/config/usb_gadget
#     echo "" > pi4/UDC
#     rmdir pi4/configs/c.1/strings/0x409
#     #rm -f pi4/configs/c.1/ecm.usb0
#     #rmdir pi4/functions/ecm.usb0/
#     #rm -f pi4/configs/c.1/mass_storage.0
#     #rmdir pi4/functions/mass_storage.0/
#     #rm -f pi4/configs/c.1/acm.GS0
#     #rmdir pi4/functions/acm.GS0/
#     rm -f pi4/configs/c.1/rndis.usb0
##    rmdir pi4/functions/rndis.usb0/
#     rm -f pi4/os_desc/c.1
#     rmdir pi4/configs/c.1/
#     rmdir pi4/strings/0x409
#     rmdir pi4
exit 0
