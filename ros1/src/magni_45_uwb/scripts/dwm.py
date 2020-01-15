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
            print("Parsing line: " + data)
            m = re.match(r"POS,(.*),(.*),(.*),.*", data)
            if m:
                print("match found!")
                print(m.group(1))
                print(m.group(2))
                print(m.group(3))
                last_parsed = rospy.Time.now()
            else:
                if (rospy.Time.now() - last_parsed).to_sec() > 15:
                    print("Timeout, resetting decawave...")
                    # Waited too long, something probably failed
                    start(ser)
                    last_parsed = rospy.Time.now()
                    pass

            if not rospy.is_shutdown():
                try:
                    (trans, rot) = tf_listener.lookupTransform('map','base_link',
                            rospy.Time(0))
                except(tf.LookupException,
                        tf.ConnectivityException,
                        tf.ExtrapolationException) as e:
                    print(e)
                    pass
                pub.publish(data)
            time.sleep(0.01)
        except Exception as e:
            print(e)
            break
        except KeyboardInterrupt:
            print("C")
            print("Keyboard Interrupt registered.")
            break

if __name__ == "__main__":
    ser = serial.Serial()
    ser.port = '/dev/decawave'
    ser.baudrate = 115200
    ser.bytesize = serial.EIGHTBITS
    ser.parity = serial.PARITY_NONE
    ser.stopbits = serial.STOPBITS_ONE
    ser.timeout = 1

    # Specify topics to listen and publish to here
    # pub = rospy.Publisher('/uwb/pos', PoseWithCovarianceStamped, queue_size=10)
    pub = rospy.Publisher('/uwb/pos', String, queue_size=10)
    rospy.init_node('uwb_publisher')
    tf_listener = tf.TransformListener()
    try:
        start(ser)
        listen(ser, pub, tf_listener)
    finally:
        ser.write(b'lep\r')
        ser.close()
