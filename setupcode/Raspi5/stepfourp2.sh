echo "Starting part 2 of setup for USB gadget..."
cat > ~/start-dji-usb-gadget.sh << 'EOF1-start-dji-usb-gadget.sh'
#!/bin/bash
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
cd /sys/kernel/config/usb_gadget/pi
cfg=configs/c.1
mkdir -p "${cfg}"
echo 0x80 > ${cfg}/bmAttributes
echo 250 > ${cfg}/MaxPower

check_file "${cfg}/bmAttributes" || exit 1
check_file "${cfg}/MaxPower" || exit 1

cfg_str=''
udc_dev=fe980000.usb
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
EOF1-start-dji-usb-gadget.sh
echo "(exec home/samalab/startup-bulk /dev/usb-ffs/bulk1 &)" >> ~/start-dji-usb-gadget.sh
echo "(exec home/samalab/startup-bulk /dev/usb-ffs/bulk2 &)" >> ~/start-dji-usb-gadget.sh
cat >> ~/start-dji-usb-gadget.sh << 'EOF2-start-dji-usb-gadget.sh'

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
EOF2-start-dji-usb-gadget.sh

echo "Making an executable"
chmod +x ~/start-dji-usb-gadget.sh

echo "Creating USB gadget service"
cat > ~/usb-gadget.service << 'EOF1-usb-gadget.service'
[Unit]
Description=Configure USB flashing port for device mode

[Service]
Type=simple
RemainAfterExit=yes
EOF1-usb-gadget.service
echo "ExecStart=$HOME/start-dji-usb-gadget.sh" >> ~/usb-gadget.service
cat >> ~/usb-gadget.service << "EOF2-usb-gadget.service"
[Install]
WantedBy=multi-user.target
EOF2-usb-gadget.service

echo "Enabling the USB gadget service"
sudo mv ~/usb-gadget.service /lib/systemd/system/
sudo systemctl daemon-reload
sudo systemctl enable usb-gadget.service
echo
