#!/bin/bash

sudo ln -s /usr/lib/arm-linux-gnueabihf/libopus.a /usr/local/lib/libopus.a
echo "Making some edits load dwc2"
filename=/boot/firmware/cmdline.txt
text='modules-load=dwc2'
file=$(realpath $filename)
echo "File path: $file"
echo "adding params to $file"
if ! grep -q -- "$text" "$file"; then
	if sudo sed -i "s/$/ $text/" "$file"; then
		echo "$text appended successfully"
	else
		echo "failure"
	fi
else
	echo "Already exists"
fi
echo

echo "Making edits enable uart0"
filename=/boot/firmware/config.txt
text='dtoverlay=uart0'
file=$(realpath $filename)
echo "File path: $file"
echo "adding params"
if ! grep -q -- "$text" "$file"; then
	sudo bash -c "echo '$text' >> $file"
	echo "$text successfully appended to $file"
else
	echo "$text already exists in $file"
fi
echo

echo "Making edits enable libcomposite"
filename=/etc/modules-load.d/libcomposite.conf
text='libcomposite'
file=$(realpath $filename)
echo "File path: $file"
echo "adding params"
if ! grep -q -- "$text" "$file"; then
        sudo bash -c "echo '$text' >> $file"
        echo "$text successfully appended to $file"
else
        echo "$text already exists in $file"
fi
echo

check_file() {
file="$1"
if [ -e ${file} ]; then
	echo "Success at ${file}"
	return 0
else
	echo "FAIL AT ${file}"
	exit 1
fi
}

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
check_file "$G/idVendor" || exit 1
check_file "$G/idProduct"
check_file "$G/bcdUSB"

echo 0xEF > bDeviceClass
echo 0x02 > bDeviceSubClass
echo 0x01 > bDeviceProtocol
check_file "$G/bDeviceClass"
check_file "$G/bDeviceSubClass"
check_file "$G/bDeviceProtocol"


mkdir -p strings/0x409
G2="/sys/kernel/config/usb_gadget/pi/strings/0x409"
echo "abcdefg1234567890" >strings/0x409/serialnumber
echo "raspberry" > strings/0x409/manufacturer
echo "PI5" > strings/0x409/product
check_file "$G2/serialnumber" || exit 1
check_file "$G2/manufacturer" || exit 1
check_file "$G2/product" || exit 1



cfg=configs/c.1
mkdir -p "${cfg}"
echo 0x80 > ${cfg}/bmAttributes
echo 250 > ${cfg}/MaxPower

check_file "${cfg}/bmAttributes" || exit 1
check_file "${cfg}/MaxPower" || exit 1

cfg_str=''
udc_dev=1000480000.usb #May be different depending on dwc2/libcomposite
net_ip=192.168.55.1
net_mask=255.255.255.0

enable_rndis=1
if [ ${enable_rndis} -eq 1 ]; then
	cfg_str="${cfg_str}+RNDIS"
	func=functions/rndis.usb0
	mkdir -p "${func}"
	ln -sf "${func}" "${cfg}"
	echo 1 > os_desc/use
	echo 0xcd > os_desc/b_vendor_code
	echo MSFT100 > os_desc/qw_sign
	echo RNDIS > "${func}/os_desc/interface.rndis/compatible_id"
	echo 5162001 > "${func}/os_desc/interface.rndis/sub_compatible_id"
	ln -sf "${cfg}" os_desc
fi

check_file "os_desc/use"
check_file "os_desc/b_vendor_code"
check_file "os_desc/qw_sign" 

systemctl daemon-reload

enable_bulk=1
if [ ${enable_bulk} -eq 1 ]; then
	mkdir -p /dev/usb/ffs
	mkdir -p /dev/usb-ffs/bulk1
	mkdir -p /dev/usb-ffs/bulk2
	check_file "/dev/usb/ffs"
	check_file "/dev/usb-ffs/bulk1"
	check_file "/dev/usb-ffs/bulk2"

	cfg_str="${cfg_str}+BULK1"
	func=functions/ffs.bulk1
	mkdir -p "${func}"
	check_file "${func}"
	ln -sf "${func}" configs/c.1/


	cfg_str="${cfg_str}+BULK2"
        func=functions/ffs.bulk2
        mkdir -p "${func}"
	check_file "${func}"
        ln -sf "${func}" configs/c.1/

 	mount -o mode=0777 -t functionfs bulk1 /dev/usb-ffs/bulk1
    	mount -o mode=0777 -t functionfs bulk2 /dev/usb-ffs/bulk2
	sudo /home/samalab/startup-bulk /dev/usb-ffs/bulk1 &
	sudo /home/samalab/startup-bulk /dev/usb-ffs/bulk2 &
    	sleep 3

    	mkdir -p "${cfg}/strings/0x409"
    	echo "${cfg_str:1} " > "${cfg}/strings/0x409/configuration"
	check_file "${cfg}/strings/0x409"
fi
udevadm settle -t 5 || :
ls /sys/class/udc > UDC
/sbin/brctl addbr br0
/sbin/ifconfig br0 ${net_ip} netmask ${net_mask} up

if [ ${enable_rndis} -eq 1 ]; then
    /sbin/brctl addif br0 usb0
    /sbin/ifconfig usb0 down
    /sbin/ifconfig usb0 up
fi

echo "Finished USB bulk device creation!"
exit 0
