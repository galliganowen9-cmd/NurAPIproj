import RPi.GPIO as GPIO
import time
import subprocess
import socket
import signal
import os
GPIO.setmode(GPIO.BCM)
GPIO.setup(2,GPIO.IN)
cmd = ["sudo", "/home/rsp/Payload-SDK/build/bin/dji_sdk_demo_linux_cxx"]
p = subprocess.Popen(
    cmd,
    stdout=subprocess.PIPE,
    stderr=subprocess.STDOUT,
    stdin=subprocess.PIPE,
    text=True,
    bufsize=1
    )

cmd2 = ["sudo", "pkill", "-f", "dji_sdk_demo_linux_cxx"]
while True:
    state= GPIO.input(2)
    print(state)
    if (state == 0):
        print("Terminate request")
        subprocess.run(cmd2)
        break
print("Done")

