#!/bin/bash
echo "Part 1 creates the usbgadget folder, and populates it with identifiers or descriptors"
cd /sys/kernel/config/usb_gadget/
mkdir -p pi

cd pi
G="/sys/kernel/config/usb_gadget/pi"
#echo 0x1d6b > idVendor # Linux Foundation
#echo 0x0104 > idProduct # Multifunction Composite Gadget
echo 0x0955 > idVendor # Linux foundation
echo 0x7020 > idProduct # Multifunction Composite Gadget
echo 0x0200 > bcdUSB #USB2
if [ -e $G/idVendor ] && [ -e $G/idProduct ] && [ -e $G/bcdUSB ]; then
	echo "Identifiers successfully created"
else
	echo "Failure to ceate identifier"
fi

echo 0xEF > bDeviceClass
echo 0x02 > bDeviceSubClass
echo 0x01 > bDeviceProtocol
if [ -e $G/bDeviceClass ] && [ -e $G/bDeviceSubClass ] && [ -e $G/bDeviceProtocol ]; then
	echo "Descriptors successfully created"
else
	echo "Failure to create descriptors"
fi

mkdir -p strings/0x409
G2="/sys/kernel/config/usb_gadget/pi/strings/0x409"
echo "abcdefg1234567890" >strings/0x409/serialnumber
echo "raspberry" > strings/0x409/manufacturer
echo "PI5" > strings/0x409/product
if [ -e $G2/serialnumber ] && [ -e $G2/manufacturer ] && [ -e $G2/product ]; then
	echo "Done.. move to part2"
else
	echo "Failure at $G2"
fi

#Came across an issue with libcomposite and usb_gadget folder not existing
#This is an error from the kernel not being able to see libcomposite
#Changed stepthree file variable from
#file=etc/modules to file=/etc/modules-load.d/libcomposite.conf
#I than ran sudo modprobe libcomposite, this seemed to fix the issue

