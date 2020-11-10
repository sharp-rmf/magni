#!/bin/bash

# ROS1
sudo sh -c 'echo "deb http://packages.ros.org/ros/ubuntu $(lsb_release -sc) main" > /etc/apt/sources.list.d/ros-latest.list'

sudo apt-key adv --keyserver 'hkp://keyserver.ubuntu.com:80' --recv-key C1CF6E31E6BADE8868B172B4F42ED6FBAB17C654

# ROS2
sudo apt update && sudo apt install curl gnupg2 lsb-release -y
curl -s https://raw.githubusercontent.com/ros/rosdistro/master/ros.asc | sudo apt-key add -
sudo sh -c 'echo "deb [arch=$(dpkg --print-architecture)] http://packages.ros.org/ros2/ubuntu $(lsb_release -cs) main" > /etc/apt/sources.list.d/ros2-latest.list'

# RMF
curl -s http://rmf.servehttp.com/repos.key | sudo apt-key add -
sudo sh -c 'echo "deb http://rmf.servehttp.com/ubuntu/main/ $(lsb_release -cs) main" > /etc/apt/sources.list.d/rmf.list'

sudo apt-get update
