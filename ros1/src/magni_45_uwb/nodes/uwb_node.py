#!/usr/bin/env python
import rospy
from std_msgs.msg import String
import time
import serial
import tf
import re


def stream_1_sensor_1():
    # initialize serial parameters
    ser = serial.Serial()
    ser.port = '/dev/decawave'
    ser.baudrate = 115200
    ser.bytesize = serial.EIGHTBITS
    ser.parity = serial.PARITY_NONE
    ser.stopbits = serial.STOPBITS_ONE
    ser.timeout = 1

    # create publisher for this data stream
    pub = rospy.Publisher('/decawave', String, queue_size=1)
    rospy.init_node('decawave')

    # Open serial port
    try:
	start(ser)
	stream_listen(ser, pub)
    except (serial.SerialException, serial.SerialTimeoutException) as e:
        rospy.loginfo("Serial Port could not be opened!")
    finally:
	ser.write(b'lep\r')
	ser.close()

def stream_listen(ser, pub):
    last_parsed = rospy.Time.now()
    while True:
        try:
            data = str(ser.readline())

            m = re.match(r"POS,(.*),(.*),(.*),.*", data)

            if m:
                print("Data found! Publishing..\n")
                last_parsed = rospy.Time.now()
            else:
                if (rospy.Time.now() - last_parsed).to_sec() > 15:
                    print("Timeout, resetting decawave...")
                    # Waited too long, something probably failed
                    start(ser)
                    last_parsed = rospy.Time.now()
                continue

            pub.publish(data)

        except Exception as e:
            print(e)
            break
        except KeyboardInterrupt:
            print("Keyboard Interrupt registered.")
            break

def start(ser):
    # Attempts to open serial port
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

if __name__ == '__main__':
    try:
        stream_1_sensor_1()
    except rospy.ROSInterruptException:
        pass
