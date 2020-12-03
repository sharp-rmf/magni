#!/bin/bash


source /opt/ros/kinetic/setup.bash
source /home/ubuntu/deployment_ws/devel/setup.bash

rostopic echo -n1 --filter "m.transforms[0].child_frame_id == 'odom' and m.transforms[0].header.frame_id == 'map'" /tf | grep translation -A 8 > /tmp/last_pose

cp /tmp/last_pose $HOME/last_pose
