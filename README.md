# ward45_magni_stack
Flash https://downloads.ubiquityrobotics.com/pi.html to SD card

Insert into Raspberry Pi 4.

Connect to HDMI monitor, keyboard and mouse.
```
# Set up networking
sudo systemctl disable pifi.service && sudo systemctl stop pifi.service
sudo vim /ec/NetworkManager/NetworkManager.conf                                             # Change managed=false to managed=true
sudo nmtui                                                                                  # Connect to Pegasus 
      # Set static route 10.233.0.0/24 via 10.233.29.1
      # Set DNS 8.8.8.8

# Configure Hostname
sudo vim /etc/hosts
sudo vim /etc/hostname                                                                      
sudo apt update && sudo apt upgrade 

# Get this package on the pi4
sudo apt install git -y
git clone git@github.com:sharp-rmf/ward45_magni_stack.git $HOME/ward45_magni_stack

# Install CMake for CycloneDDS
source $HOME/ward45_magni_stack/install_cmake.bash

# Install apt dependencies
sudo apt install python-catkin-tools python-vcstool -y

# Create Workspace
mkdir -p $HOME/deployment_ws/src
cp $HOME/ward45_magni_stack/depend.repos $HOME/deployment_ws

# Clone ROS1 dependencies
cd $HOME/deployment_ws
vcs import src < depend.repos

# Install dependencies
rosdep install

# Patch RPlidar Driver
sed -i s/#define\ DEFAULT_MOTOR_PWM\ *660/#define\ DEFAULT_MOTOR_PWM\ 1000/ src/rplidar_ros/sdk/include/rplidar_cmd.h

# Build
cd $HOME/deployment_ws
source /opt/ros/kinetic/setup.bash
catkin build --cmake-args -DBUILD_IDLC=NO  

# Copy launch files to $HOME
cp $HOME/chart_magni_stack/start_device.bash $HOME
cp $HOME/chart_magni_stack/start_free_fleet.bash $HOME
chmod +x {start_device, start_free_fleet}.bash
```
