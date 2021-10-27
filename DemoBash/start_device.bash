#!/bin/bash

source /opt/ros/kinetic/setup.bash
source /home/ubuntu/dev_ws/devel/setup.bash

roslaunch magni_45 magni_45_dual_rplidar_sick_laser.launch

#roslaunch magni_45 magni_45_dual_rplidar_sick_laser_eband.launch

#roslaunch magni_45 magni_45_single_sick_laser.launch

#Files changed to speed up launch of magni:
#
#1. /opt/ros/kinetic/share/magni_bringup/launch/base.launch
#    - Commented out rosbridge.launch
#
#2. /opt/ros/kinetic/lib/magni_bringup/launch_core.py
#    - Commented out line 50 - 76 
#    - Added line 77
