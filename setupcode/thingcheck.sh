#!/bin/bash
G=/sys/kernel/config/usb_gadget/pi4
echo "Functions"
ls -l "$G/functions"
echo
echo "Config links:"
find "$G/configs/c.1" -maxdepth 2 -type l -printf "%f -> %l\n"

echo
echo "UDC Binding:"
cat "$G/UDC"

echo
echo "UDC state:"
cat /sys/class/udc/*/state
