#!/usr/bin/env python
import rospy
from std_msgs.msg import String
from geometry_msgs.msg import Pose
import tf
import re
import numpy as np

# an Adapter holds the logic that combines data from sensors into standard ROS Pose messages and publishes them.
# These ROS Pose messages are a standard way of representation position from various different localization systems.
# A Solver takes a stream of ROS poses from two Adapters, and solves for the transformation mapping 
# points on one stream to another.
# This is an abstract template of an Adapter that is meant to be subclassed with logic specific to each localization system

class AbstractAdapter:
    def __init__(self, stream_name, stream_rate, sensor_1_topic):
        self.stream_name = stream_name
        self.stream_rate = stream_rate
        # cache of the latest message to be received from each sensor
        # Can have multiple sensors. In this case, we only have one.
        # In this example, we take the sensor input as a String
        self.sensor_1_topic = sensor_1_topic
        self.sensor_1_msg = None

        # Topic where we will publish the constructed Pose stream
        self.pub = rospy.Publisher("/easy_map_transform/{}".format(self.stream_name), Pose, queue_size=1)


    def sensor_1_callback(self, msg):
        # This callback will update self.sensor_1_msg with the latest message to come from sensor_1
        # Validation of the msg should occur here
        raise NotImplementedError

    def sensor_1_msg_to_data(self):
        # converts self.sensor_1_msg to a form to generate Pose messages more easily,
        raise NotImplementedError

    def generate_msg(self):
        # converts self.sensor_n_msgs into the Pose that will form the ROS Pose stream
        raise NotImplementedError

    def publish_stream(self, event=None):
        # This function periodically publishes a Pose message which represents the p1 data stream
        if self.sensor_1_msg:
            msg = self.generate_msg()
            self.pub.publish(msg)

    def start(self):
        # p1 publisher that publishes at a constant rate of 1Hz
        rospy.Timer(rospy.Duration(1/self.stream_rate), self.publish_stream)

        # Input Sensor 1
        sub_1 = rospy.Subscriber(self.sensor_1_topic, String, self.sensor_1_callback)

        # spin() simply keeps python from exiting until this node is stopped
        rospy.spin()

if __name__ == '__main__':
    print("This class should not be run on its own!")
