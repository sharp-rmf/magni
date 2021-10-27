#!/bin/bash


source /opt/ros/kinetic/setup.bash
source /home/ubuntu/dev_ws/devel/setup.bash

export RMW_IMPLEMENTATION=rmw_cyclonedds_cpp
export CYCLONEDDS_URI=file:///home/ubuntu/cyclonedds_local.xml

roslaunch magni magni_45_free_fleet_client.launch

