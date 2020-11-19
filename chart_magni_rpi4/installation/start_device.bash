#!/bin/bash

rfkill unblock all

nmcli device set wlx58d56e91d24f managed off
ifdown wlx58d56e91d24f
ifup wlx58d56e91d24f
ip route add 10.233.0.1/24 via 10.233.29.1
wpa_supplicant -B -i wlx58d56e91d24f -c /etc/wpa_supplicant/wpa_supplicant.conf 


source /opt/ros/kinetic/setup.bash
source /home/ubuntu/deployment_ws/devel/setup.bash
roslaunch magni_45 magni_45_dual_laser.launch
