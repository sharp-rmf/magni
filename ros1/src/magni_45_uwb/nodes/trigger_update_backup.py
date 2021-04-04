#!/usr/bin/env python
import rospy
from std_msgs.msg import String, Bool
from actionlib_msgs.msg import GoalStatusArray
import time
import serial
import tf
import re

class Trigger:
    def __init__(self):
        rospy.init_node('update_trigger')
        global last_time
        self.last_time = rospy.Time.now()
        self.to_update = True

        # Publish to this topic to trigger an interation of optimization
        self.pub = rospy.Publisher('/update_trigger', Bool, queue_size=1)
        self.move_base_sub = rospy.Subscriber("/move_base/status", GoalStatusArray, self.callback)
        self.tf_listener = tf.TransformListener()
        rospy.spin()

    def callback(self, msg):
        timestamp = msg.header.stamp
        try:
            status = msg.status_list[0].text
        except IndexError as e:
            return

        if status == 'Goal reached.':
            # Robot is stationary
            if (timestamp - self.last_time).to_sec() > 1.5 and self.to_update:
                rospy.loginfo("Robot is stationary for 3 seconds, sending update trigger..")
                self.pub.publish(True)
                self.last_time = timestamp
                self.to_update = False
        else:
            # Robot is moving
            self.last_time = timestamp
            self.to_update = True

if __name__ == '__main__':
    try:
        update_trigger = Trigger()
    except rospy.ROSInterruptException:
        pass
