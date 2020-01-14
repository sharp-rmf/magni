#!/bin/bash
PROJECT_ROOT="$HOME/dev/magni_45"
ROS_DISTRO="kinetic"

# Required packages and one-time setup 
sudo apt install picocom -y
sudo apt install python3-vcstool -y
sudo apt install python3-pip -y
sudo apt install npyscreen -y
sudo apt install ros-$ROS_DISTRO-move-base -y
sudo apt install ros-$ROS_DISTRO-dwa-local-planner -y

echo "Copying udev rules.."
sudo cp $PROJECT_ROOT/ros1/udev/*.rules /etc/udev/rules.d
sudo udevadm trigger
