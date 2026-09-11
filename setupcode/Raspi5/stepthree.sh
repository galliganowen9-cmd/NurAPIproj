#!/bin/bash
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


