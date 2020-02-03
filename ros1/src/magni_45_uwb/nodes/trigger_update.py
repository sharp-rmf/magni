#!/usr/bin/env python
import rospy
from std_msgs.msg import String, Bool
from actionlib_msgs.msg import GoalStatusArray
import time
import serial
import tf
import re
import numpy as np

class Trigger:
    def __init__(self):
        rospy.init_node('update_trigger')
        global last_time
        self.last_time = rospy.Time.now()
        self.to_update = True
	self.transform_to_nav_frame = np.array([
	        [0.015322908908635599, -0.9804653130438025, 14.34677179077444],
                [0.9804653130438025, 0.015322908908635599, 6.608554966414207],
                [0, 0, 1]
                ])

        # Publish to this topic to trigger an interation of optimization
        self.pub = rospy.Publisher('/update_trigger', Bool, queue_size=1)
        self.tf_listener = tf.TransformListener()
        self.sensor_pub = rospy.Subscriber("/decawave", String, self.sensor_callback)
        self.last_sensor_reading = None

        while not rospy.is_shutdown():
            if self.last_sensor_reading == None:
                continue
            try:
                now = rospy.Time(0)
                self.tf_listener.waitForTransform('/map', '/base_link', now, rospy.Duration(4.0))
                (trans_bef, rot_bef) = self.tf_listener.lookupTransform('/map', '/base_link' , now)
                rospy.sleep(5)
                (trans_now, rot_now) = self.tf_listener.lookupTransform('/map', '/base_link' , rospy.Time(0))
                amt_of_motion = np.sum((np.array(trans_now) - np.array(trans_bef))**2)
                amt_of_error = np.sum((trans_now[0:2] - self.last_sensor_reading)**2)

                if amt_of_motion < 0.5:
                    # Robot is stationary
                    # self.pub.publish(Bool())
                    pass
                else:
                    #robot is moving
                    # if decawave reading and tf diverges by too much, update
                    while amt_of_error > 1.0:
                        self.pub.publish(Bool())
                        (trans_now, rot_now) = self.tf_listener.lookupTransform('/map', '/base_link' , rospy.Time(0))
                        amt_of_error = np.sum((trans_now[0:2] - self.last_sensor_reading)**2)
                        rospy.sleep(0.1)

            except (tf.LookupException, tf.ConnectivityException) as e:
                print(e)
                continue

    def sensor_callback(self, msg):
        m = re.match(r"POS,(.*),(.*),(.*),.*", msg.data)
        dwm_point = np.array([float(m.group(1)), float(m.group(2)), 1])
        self.last_sensor_reading = np.dot(self.transform_to_nav_frame, dwm_point)[0:2]

if __name__ == '__main__':
    try:
        update_trigger = Trigger()
    except rospy.ROSInterruptException:
        pass
