#!/bin/bash

sudo rfkill unblock all

sudo nmcli device set wlx58d56e91d24f managed off
sudo ifdown wlx58d56e91d24f
sudo ifup wlx58d56e91d24f
sudo ip route add 10.233.0.1/24 via 10.233.29.1
sudo wpa_supplicant -B -i wlx58d56e91d24f -c /etc/wpa_supplicant/wpa_supplicant.conf 
sudo dhclient wlx58d56e91d24f


source /opt/ros/kinetic/setup.bash
source $HOME/deployment_ws/devel/setup.bash
roslaunch magni_45 magni_45.launch
