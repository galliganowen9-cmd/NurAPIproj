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
