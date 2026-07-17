#!/bin/bash
#GNU AWK (sudo apt gawk) required!
#Program filters through hex data to return RSSI, and other related metadata
#
G="/home/samalab/NurAPI/data"
sudo awk 'NF >= 2 && $2 !~ /^a50/ {
	print $1 " " substr($2,27) 
}' $G/data.txt > $G/orgdata.txt
sudo awk '{
	print $1 " " substr($2,1,length($2)-4) " "

}' $G/orgdata.txt > $G/tempdata2.txt && mv $G/tempdata2.txt $G/orgdata.txt

sudo awk '{
	for (i = 1;i<=NF;i++){
		print $i
	}
}' $G/orgdata.txt > $G/tempdata2.txt && mv $G/tempdata2.txt $G/orgdata.txt

sudo awk '{
	if (NR %2 == 0){
        	for (i=1;i<=length($0);i++){
               		if (i == 1){
                        	c = substr($0,i,2)
                        	size = strtonum("0x" c)
                        	nextpos = (2*size+i)+2
                	}
                	else if (i == nextpos){
                        	printf "\n"
                        	c = substr($0,i,2)
                        	size = strtonum("0x" c)
                        	nextpos = (2*size+i)+2
                	}
                	printf "%s", substr($0,i,1)
        	}
		printf "\n"
	}
	else{
		print $0
	}
}' $G/orgdata.txt > $G/tempdata2.txt && mv $G/tempdata2.txt $G/orgdata.txt

sudo awk '{
        if ($0 ~ /^[0-9]+\.[0-9]+$/){
		printf "\n"
                print "{Session begin at}: " $0
		print "{UTC time}: " ($0%86400)
        }
        else{
		print "[METADATA]: " $0
                x = strtonum("0x" substr($0,3,2))
                if (x>=128){
                x -= 256
                }
                print "[RSSI]: " x
                le = substr($0,7,4)
                be = substr(le,3,2) substr(le,1,2)
                value = strtonum("0x" be)
                print "[T.A.S Millisec]: " value " ms"
	}
}' $G/orgdata.txt > $G/tempdata2.txt && mv $G/tempdata2.txt $G/orgdata.txt
