#!/bin/bash
function output_average() {
    if (have_utc) {
        if (rssi_count > 0)
            printf "%.2f\n", rssi_sum / rssi_count >> rssi_file
        else
            print "NaN" >> rssi_file
    }
}

BEGIN {
    output_dir = "/home/samalab/NurAPI/data/organizeddata"
    utc_file  = output_dir "/rfid_utc_values.txt"
    rssi_file = output_dir  "/average_rssi.txt"

    # Clear old output files
    printf "%s", "" > utc_file
    printf "%s", "" > rssi_file
    close(utc_file)
    close(rssi_file)
}

/^\{UTC time\}:/ {
    # Finish the previous UTC group
    output_average()

    utc = $NF
    print utc >> utc_file

    rssi_sum = 0
    rssi_count = 0
    have_utc = 1
    next
}

/^\[RSSI\]:/ && have_utc {
    rssi_sum += $NF
    rssi_count++
}

END {
    # Output the final UTC group's average
    output_average()
}
