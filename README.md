# Magni
## This repo is used for Magni and it's associated robots.

# Setup
VCS is used for the setup because it's easier to work with:
https://github.com/dirk-thomas/vcstool/issues/221

## Magni
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
## Romio
Pull the repo, install the dependencies and build the repo.
```
mkdir -p ~/magni_ws/src
cd ~/magni_ws
wget https://raw.githubusercontent.com/sharp-rmf/magni/main/magni.repos
vcs import src < rmf.repos
sudo apt-get update && \
    rosdep update && \
    rosdep install -y \
      --from-paths \
        src \
      --ignore-src -r \
    && catkin build --cmake-args -DBUILD_IDLC=NO
```
Additional files (optional)

```
# Patch RPlidar Driver
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

# catkin build settings when building on raspberry pi
```
echo 'alias magni_build="catkin build -j 1 -p 1 --mem-limit 50% --cmake-args -DBUILD_IDLC=NO' >> ~/.bashrc
cd ~/catkin_ws 
magni_build
```
# Magni RPLIDAR-A3 Navigation

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

# Rplidar reference for setting up udev rules
https://github.com/robopeak/rplidar_ros/wiki