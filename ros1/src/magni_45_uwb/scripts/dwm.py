#!/usr/bin/env python

from __future__ import print_function
import time
import serial
import rospy
from geometry_msgs.msg import PoseWithCovarianceStamped
from std_msgs.msg import String
import tf
import re


def start(ser):
    try:
        print("Attemping to open and read decawave..")
        ser.close()
        ser.open()
        ser.write(b'\r\r')
        time.sleep(1)
        ser.write(b'lep\r')
    except Exception as e:
        print(e)
        return


def listen(ser, pub, tf_listener):

    last_parsed = rospy.Time.now()
    while True:
        try:
            data = str(ser.readline())

            # parse data
	    if data != '':
		print("Parsing line: " + data)

	    m = re.match(r"POS,(.*),(.*),(.*),.*", data)

            if m:
                print("match found!\n")
                last_parsed = rospy.Time.now()
            else:
                if (rospy.Time.now() - last_parsed).to_sec() > 15:
                    print("Timeout, resetting decawave...")
                    # Waited too long, something probably failed
                    start(ser)
                    last_parsed = rospy.Time.now()
		continue

	    # Print received decawave position
	    x = float(m.group(1))
	    y = float(m.group(2))
	    z = float(m.group(3))
	    print("{},{},{}".format(x, y, z))

            # Get current robot pose
            if not rospy.is_shutdown():
                try:
                    (trans, rot)=tf_listener.lookupTransform('map', 'base_link',
                                                               rospy.Time(0))
                except(tf.LookupException,
                        tf.ConnectivityException,
                        tf.ExtrapolationException) as e:
                    print(e)
                    continue

            msg=construct_pose_update(x, y, z, rot)
            pub.publish(msg)
            time.sleep(0.01)

        except Exception as e:
            print(e)
            break
        except KeyboardInterrupt:
            print("Keyboard Interrupt registered.")
            break


def construct_pose_update(x, y, z, rot):
    msg=PoseWithCovarianceStamped()
    msg.header.frame_id="map"
    msg.header.stamp=rospy.Time.now()
    msg.pose.pose.position.x=x
    msg.pose.pose.position.y=y
    msg.pose.pose.position.z=0
    msg.pose.covariance=[0.25, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.25, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0,
                            0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0685]
    msg.pose.pose.orientation.x = rot[0]
    msg.pose.pose.orientation.y = rot[1]
    msg.pose.pose.orientation.z = rot[2]
    msg.pose.pose.orientation.w = rot[3]
    return msg


if __name__ == "__main__":
    ser=serial.Serial()
    ser.port='/dev/decawave'
    ser.baudrate=115200
    ser.bytesize=serial.EIGHTBITS
    ser.parity=serial.PARITY_NONE
    ser.stopbits=serial.STOPBITS_ONE
    ser.timeout=1

    # Specify topics to listen and publish to here
    # pub = rospy.Publisher('/uwb/pos', PoseWithCovarianceStamped, queue_size=10)
    pub=rospy.Publisher(
        '/initialpose', PoseWithCovarianceStamped, queue_size=10)
    rospy.init_node('uwb_publisher')
    tf_listener=tf.TransformListener()
    try:
        start(ser)
        listen(ser, pub, tf_listener)
    finally:
        ser.write(b'lep\r')
        ser.close()
