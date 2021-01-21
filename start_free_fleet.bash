#!/bin/bash


source /opt/ros/kinetic/setup.bash
source /home/ubuntu/deployment_ws/devel/setup.bash

export RMW_IMPLEMENTATION=rmw_cyclonedds_cpp
export CYCLONEDDS_URI=file:///home/ubuntu/cyclonedds.xml

# roslaunch magni_45 magni_45_free_fleet_client.launch
