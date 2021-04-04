#!/bin/sh
rostopic pub /initialpose geometry_msgs/PoseWithCovarianceStamped """header:
  seq: 1
  stamp:
    secs: 1602139034
    nsecs: 964688329
  frame_id: "map"
pose:
  pose:
    position:
      x: 9.77401447296
      y: 9.13193511963
      z: 0.0
    orientation:
      x: 0.0
      y: 0.0
      z: -0.707
      w: 0.707
  covariance: [0.25, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.25, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.06853892326654787]"""
