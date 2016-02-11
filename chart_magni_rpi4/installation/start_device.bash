#!/bin/bash

sudo rfkill unblock all

sudo nmcli device set wlx58d56e91d24f managed off
sudo ifdown wlx58d56e91d24f
sudo ifup wlx58d56e91d24f
sudo ip route add 10.233.0.1/24 via 10.233.29.1

source /opt/ros/kinetic/setup.bash
#@source $HOME/deployment_ws/devel/setup.bash
#echo "Running Node"
