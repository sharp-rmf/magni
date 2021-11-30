# Romio
This repo is used for Magni and it's associated robots.

## Latest bash script
For spinning everything up, use the romio.bash script in DemoBash folder at the root of this repo.
DemoBash folder is usually symlinked to the root of the workspace for easy access.

# Setup
VCS is used for the setup because it's easier to work with:
https://github.com/dirk-thomas/vcstool/issues/221

### Magni
Flash https://downloads.ubiquityrobotics.com/pi.html to SD card

Insert into Raspberry Pi 4.

Connect to HDMI monitor, keyboard and mouse.

For reference, the forward direction for the Magni is defined as the vector from the robot center towards the motor controller board.
```
# Set up networking
sudo systemctl disable pifi.service && sudo systemctl stop pifi.service


### To be changed to use nmcli #####################################
# sudo vim /ec/NetworkManager/NetworkManager.conf                                             # Change managed=false to managed=true
# sudo nmtui                                                                                  # Connect to Pegasus 
#      # Set static route 10.233.0.0/24 via 10.233.29.1
#      # Set DNS 8.8.8.8
####################################################################

# Configure Hostname
sudo vim /etc/hosts
sudo vim /etc/hostname                                                                      
# sudo apt update && sudo apt upgrade # Might not be necessary.
```
### Romio
Pull the repo, install the dependencies and build the repo.
### Install dependencies
```
apt-get update && sudo apt-get install -y \
    python3-catkin-tools \
    git python3-vcstool \
    wget qt5-default \
    python3-colcon-common-extensions \
    libpcap-dev 
    
```
### Pull the repo
```
source /opt/ros/melodic/setup.bash
mkdir -p ~/magni_ws/src
cd ~/magni_ws
wget https://raw.githubusercontent.com/sharp-rmf/magni/main/magni.repos
vcs import src < magni.repos # Note this would cause a duplicate magni.repos in ~/magni_ws/src/magni/magni.repos

# Patch Rplidar
./src/magni/magni/scripts/patch_rplidar_driver.sh 

sudo apt-get update && \
    rosdep update && \
    rosdep install -y \
      --from-paths \
        src \
      --ignore-src -r \
    && catkin build --cmake-args -DBUILD_IDLC=NO
```
### Important note after build completes
For obvious reason, the maps used by romio/magni is not committed to the repo. At this point it would be good to grab the maps from whoever has it.
### Additional files (optional)

```
# Patch RPlidar Driver # This might not be neccessary
sed -i s/#define\ DEFAULT_MOTOR_PWM\ *660/#define\ DEFAULT_MOTOR_PWM\ 1000/ src/rplidar_ros/sdk/include/rplidar_cmd.h

# Copy launch files to $HOME (OUTDATED, TO BE CHANGED 15 Sep 2021, jun_hao_chng@cgh.com.sg)
cp $HOME/magni/start_device.bash $HOME
cp $HOME/magni/start_free_fleet.bash $HOME
chmod +x {start_device,start_free_fleet}.bash

# Copy udev rules, remember to change ENV{ID_PATH} based on the output from `sudo udevadm info /dev/ttyUSB*` based on your lidar device id 
sudo cp $HOME/magni/*.rules /etc/udev/rules.d # (OUTDATED, TO BE CHANGED 15 Sep 2021, jun_hao_chng@cgh.com.sg)
sudo udevadm trigger

# Add deployment_ws environment to .bashrc
echo "source $HOME/deployment_ws/devel/setup.bash" >> ~/.bashrc
```

## Important configurations

### TODO: Tuning navigation (move_base parameters)

# Time synchronization
If you are commanding the movement of the magni (/cmd_vel subscriber on the raspberry Pi) with another PC (/cmd_vel publisher on a NUC linked via ethernet to the Pi), then time synchronization is required. The Romio uses chronyc to synchronise the time. The two scripts can be found at magni/chrony_config.

To use these files, the client and server both needs to have the chrony.service running. So 'sudo apt install chrony' on both, and check that it is up by running 'systemctl list-units chrony.service'. Make sure to change the Ip addresses in the config files to match.

I.e. In the client, the line "server 192.168.1.102 iburst" should be changed to whatever the server's ip address is. In the server, the line "allow 192.168.1/16" should be changed to whatever you need.

Then save the chron_server.conf into /etc/chrony/chrony.conf in the server. Save chron_client.conf into /etc/chrony/chrony.conf in the client.

If all else fails, use:
```
# On the chrony server, ssh into the client and run the following (assuming the client is on a localnet with the server)
sshpass -p chart123 ssh ubuntu@192.168.1.100'
sudo -S chronyc -a '"'burst 4/4'"
sudo -S chronyc -a makestep'
```
### catkin build settings when building on raspberry pi
```
echo 'alias magni_build="catkin build -j 1 -p 1 --mem-limit 50% --cmake-args -DBUILD_IDLC=NO' >> ~/.bashrc
cd ~/catkin_ws 
magni_build
```
### Magni RPLIDAR-A3 Navigation

This repo contains packages that configure the ROS 1 nav stack for Magni with a
RPLIDAR-A3.

If using anything other than the "stock" Magni Raspberry Pi 3 image, the
`udev` rules files in the `udev` directory should help things become more
consistent across reboots. Just copy them into `/etc/udev/rules.d`. You can
then run `sudo udevadm trigger` to avoid having to reboot immediately after
the copy. Future bootups will use the files by default.

The rule file in the `udev` directory is only necessary if you are running
on a NUC (or anything other than Raspberry Pi). It just tries to identify
a FTDI USB-Serial IC and symlink it to `/dev/magni`. It also looks for the
RPLIDAR usb-serial gadget and symlinks it to `/dev/rplidar`.

After loading the "stock" parameter file from Ubiquity Robotics, we then
overlay our own parameter to clobber the stock value with what is passed
in by our launch file, so that we can configure the Magni serial port in
our own site- and robot-specific launch files.

### Rplidar reference for setting up udev rules
https://github.com/robopeak/rplidar_ros/wiki

# Dockerfile
Instructions to use dockerfile:
```
cd ~/magni_ws/src/magni
# If you are running docker build for the first time, 
# this might take awhile as it needs to grab all the dependencies to build the docker image.
docker build -t romio . && docker run -it 
```
After running docker run, you should enter a mock-up container of your complete magni workspace with functioning ROS packages.

# VNC setup
VNC is a useful tool for troubleshooting, here is how to set it up quickly
### Dependencies (for the GNOME landing page on your robot hosting the vncserver i.e. the magni)
```
sudo apt update && sudo apt-get install gnome-panel gnome-settings-daemon metacity nautilus gnome-terminal vnc4server
```
### Setup your password
```
vncpasswd
```
Reference: https://computingforgeeks.com/how-to-install-vnc-server-on-ubuntu/
### Edit the vnc startup file

#### A suitable vncserver for kinetic could not be found: https://packages.ubuntu.com/search?keywords=tigervnc-standalone-server
Reference: https://askubuntu.com/questions/475023/how-to-make-vnc-server-work-with-ubuntu-desktop-without-xfce.
https://www.teknotut.com/en/install-vnc-server-with-gnome-display-on-ubuntu-18-04/
```
#!/bin/sh

# Sample file from RoMio

# Start Gnome 3 Desktop 
#[ -x /etc/vnc/xstartup ] && exec /etc/vnc/xstartup
#[ -r $HOME/.Xresources ] && xrdb $HOME/.Xresources
#vncconfig -iconic &
#dbus-launch --exit-with-session gnome-session &

xrdb $HOME/.Xresources
xsetroot -solid black
dbus-launch --exit-with-session gnome-session &
```
### Start/ Kill vncserver 
```
# Start
vncserver :1 -localhost=no -geometry 800x600 -depth 24 
# Kill
vncserver -kill :1
```
### Connect to the vncserver
I use tigervnc for this, simply connect to IP_ADDRESS:PORT_NUMBER with your password
```
# Check your ip and port number of the vncserver
lsof -i | grep vnc # For the port number
ip a # For the ip address
```