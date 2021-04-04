#!/usr/bin/env python
import rospy
from std_msgs.msg import String, Bool
from geometry_msgs.msg import Pose, PoseWithCovarianceStamped
from AbstractAdapter import AbstractAdapter
import tf
import re
import numpy as np

class DecawaveAdapter(AbstractAdapter):
    def __init__(self, stream_name, stream_rate, sensor_1_topic):
        AbstractAdapter.__init__(self, stream_name, stream_rate, sensor_1_topic)
	self.transform_to_nav_frame = np.array([
	        [0.015322908908635599, -0.9804653130438025, 14.34677179077444],
                [0.9804653130438025, 0.015322908908635599, 6.608554966414207],
                [0, 0, 1]
                ])

        self.tf_listener = tf.TransformListener()
        self.update_pub = rospy.Publisher(stream_name, PoseWithCovarianceStamped, queue_size=10)

    def update_callback(self, msg):
        # this callback will trigger an update of robot pose using the last known decawave position
        # Validation of the msg should occur here
        rospy.loginfo("Updating robot pose!")
        if self.sensor_1_msg:
            rospy.loginfo("Publishing pose estimate from decawave..")
            self.update_pub.publish(self.generate_msg())
        return

    def sensor_1_callback(self, msg):
        # This callback will update self.sensor_1_msg with the latest message to come from sensor_1
        # Validation of the msg should occur here
        # rospy.loginfo("Received decawave data!")
        m = re.match(r"POS,(.*),(.*),(.*),.*", msg.data)
        if m:
            self.sensor_1_msg = msg
        return

    def sensor_1_msg_to_data(self):
        # converts self.sensor_1_msg to a form to generate Pose messages more easily. 
        # In this case, we receive String messages.
        # The function parses the String into a representation that more easily populates a Pose message.
        # In this case, a numpy array
        m = re.match(r"POS,(.*),(.*),(.*),.*", self.sensor_1_msg.data)
        dwm_point = np.array([float(m.group(1)), float(m.group(2)), 1])
        return np.dot(self.transform_to_nav_frame, dwm_point)

    def generate_msg(self):
        # converts self.sensor_n_msgs into the Pose that will form the ROS Pose stream
        sensor_1_data = self.sensor_1_msg_to_data()
        msg = PoseWithCovarianceStamped()
        msg.header.frame_id = "map"
        msg.header.stamp = rospy.Time.now()
        msg.pose.pose.position.x = sensor_1_data[0]
        msg.pose.pose.position.y = sensor_1_data[1]
        msg.pose.pose.position.z = 0.0
        
        (trans, rot) = self.tf_listener.lookupTransform("map", "base_link", rospy.Time(0))
        msg.pose.covariance = [0.02, 0.0, 0.0, 0.0, 0.0, 0.0, 
                                0.0, 0.02, 0.0, 0.0, 0.0, 0.0, 
                                0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 
                                0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 
                                0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 
                                0.0, 0.0, 0.0, 0.0, 0.0, 0.8]
        msg.pose.pose.orientation.x = rot[0]
        msg.pose.pose.orientation.y = rot[1]
        msg.pose.pose.orientation.z = rot[2]
        msg.pose.pose.orientation.w = rot[3]

        return msg

    def publish_stream(self, event=None):
        # This function periodically publishes a Pose message which represents the p1 data stream
        if self.sensor_1_msg:
            msg = self.generate_msg()
            self.pub.publish(msg)

    def start(self):
        # p1 publisher that publishes at a constant rate of 1Hz

        # Input Sensor 1
        sub_1 = rospy.Subscriber(self.sensor_1_topic, String, self.sensor_1_callback)

        # Input Sensor 2
        sub_2 = rospy.Subscriber("/update_trigger", Bool, self.update_callback)

        # spin() simply keeps python from exiting until this node is stopped
        rospy.spin()

if __name__ == '__main__':
    rospy.init_node('stream_adapter', anonymous=True)

    sensor_1_topic = str(rospy.get_param('~sensor_1_topic'))
    stream_name = str(rospy.get_param('~stream_name'))
    stream_rate = float(rospy.get_param('~stream_rate'))

    sensor_adapter = DecawaveAdapter(stream_name, stream_rate, sensor_1_topic)
    sensor_adapter.start()
