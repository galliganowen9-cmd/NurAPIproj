import RPi.GPIO as GPIO
import time
import subprocess
import socket
import signal
import os
GPIO.setmode(GPIO.BCM)
GPIO.setup(2,GPIO.IN)
print(GPIO.input(2))
packetsend = bytes.fromhex(
    "a5 06 00 00 00 5c 39 00 00 0a 14 fa"    
)

packetping = bytes.fromhex(
    "a5 03 00 00 00 59 01 d1 f1"    
)
packetread = bytes.fromhex(
    "a5 04 00 00 00 5e 07 01 b9 94"
)
packetclear = bytes.fromhex(
    "a5 03 00 00 00 59 05 55 b1"
    
)
print("packet initialized")
cmd1 = ["sudo", "/home/samalab/git/Payload-SDK/build/bin/dji_sdk_demo_linux_cxx"]
cmd2 = ["sudo", "pkill", "-f",  "dji_sdk_demo_linux_cxx"]
while True:
    stateone = GPIO.input(2)
    if (stateone == 0): #flip to brk to continue
        break
s = socket.socket()
print("Socket created")
s.connect(('172.168.253.150',4333))
print("Socket connected")
p = subprocess.Popen([
    "sudo",
    "tshark",
    "-i",
    "eth0",
    "-f",
    "tcp port 4333",
    "-w",
    "/tmp/capture3.pcap"
    ])
pdji = subprocess.Popen(cmd1,stdout=subprocess.DEVNULL,stderr=subprocess.DEVNULL)
print("setting up shark, running DJI program")
time.sleep(6)
print("sending commands")
s.sendall(packetping)
time.sleep(0.5)
while True:
   
    s.sendall(packetsend)
    time.sleep(21.4)
    state= GPIO.input(2)
    if (state == 0): #flip to brk to continue
        subprocess.run(cmd2)
        break
print("Scanning end,DJI end")
""" 
s.sendall(packetread)
time.sleep(0.5)
s.sendall(packetclear)
time.sleep(0.5)"
"""
print("Done, terminating shark")

try:
    p.send_signal(signal.SIGINT)
    print("wait")
    p.wait(timeout = 5)
except subprocess.TimeoutExpired:
    print("Timeout please continue..")

print("Done")

with open("/home/samalab/NurAPI/data/data.txt", "w") as f:
    p2 = subprocess.Popen([
        "sudo",
        "tshark",
        "-r",
        "/tmp/capture3.pcap",
        "-Y",
        "tcp.len>0",
        "-T",
        "fields",
        "-e",
        "frame.time_epoch",
        "-e"
        "tcp.payload",
        ], stdout = f)
    
time.sleep(2)
print("end")

path = "/tmp/capture3.pcap"
if os.path.exists(path):
    subprocess.run([
        "sudo",
        "rm",
         "-f",
        "/tmp/capture3.pcap"
       
       ])

print("Done, Filtering for RSSI")
subprocess.run(["sudo","/home/samalab/NurAPI/filter/filchange.sh"])
