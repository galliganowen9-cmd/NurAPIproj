/* Update software repository */
sudo apt-get update
sudo apt-get upgrade

 /* Install libaio */
sudo apt-get install automake
sudo apt-get install libaio-dev

/* Download opus-1.3.1 source code from https://opus-codec.org/ and install it */
/* Change the program below to match your file in downloads */
tar -xzvf /home/pi/Downloads/opus-1.6.1.tar.gz
sudo mv opus-1.6.1 /home/pi/
cd opus-1.6.1/
autoreconf -f -i
./configure
 make -j4 && sudo make install


/* Install libusb */
sudo apt-get install libusb-1.0-0-dev
