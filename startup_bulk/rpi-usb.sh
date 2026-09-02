#!/bin/bash
# Set up a Raspberry Pi 4 as a USB-C Ethernet Gadget
# Based on:
#     - https://www.hardill.me.uk/wordpress/2019/11/02/pi4-usb-c-gadget/
#     - https://pastebin.com/VtAusEmf

if ! $(grep -q dtoverlay=dwc2 /boot/config.txt) ; then
    echo "Add the line dtoverlay=dwc2 to /boot/config.txt"
    exit
fi

if ! $(grep -q modules-load=dwc2 /boot/cmdline.txt) ; then
    echo "Add the line modules-load=dwc2 to /boot/cmdline.txt"
    exit
fi

if ! $(grep -q libcomposite /etc/modules) ; then
    echo "Add the line libcomposite to /etc/modules"
    exit
fi

if ! $(grep -q "denyinterfaces usb0" /etc/dhcpcd.conf) ; then
    echo "Add the line denyinterfaces usb0 to /etc/dhcpcd.conf"
    exit
fi

if [[ ! -e /usr/sbin/dnsmasq ]] ; then
    echo "Install dnsmasq"
    exit
fi

if [[ ! -e /etc/dnsmasq.d/usb ]] ; then
    echo "interface=usb0" > /etc/dnsmasq.d/usb
    echo "dhcp-range=10.55.0.2,10.55.0.6,255.255.255.248,1h" >> /etc/dnsmasq.d/usb
    echo "dhcp-option=3" >> /etc/dnsmasq.d/usb
    echo "leasefile-ro" >> /etc/dnsmasq.d/usb
    echo "Created /dnsmasq.d/usb"
fi

if [[ ! -e /etc/network/interfaces.d/usb0 ]] ; then
    echo "auto usb0" > /etc/network/interfaces.d/usb0
    echo "allow-hotplug usb0" >> /etc/network/interfaces.d/usb0
    echo "iface usb0 inet static" >> /etc/network/interfaces.d/usb0
    echo "  address 192.168.55.1" >> /etc/network/interfaces.d/usb0
    echo "  netmask 255.255.255.0" >> /etc/network/interfaces.d/usb0
    echo "Created /etc/network/interfaces.d/usb0"
fi

echo "Done"