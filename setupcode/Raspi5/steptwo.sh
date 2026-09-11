#!/bin/bash
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
