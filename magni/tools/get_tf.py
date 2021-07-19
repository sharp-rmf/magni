#!/usr/bin/env python3

import nudged
from math import pi

# Sample Groundtruth set: [rot: -1.57, 1, [1,0]], with error=0
# points_set1 = [[0,0], [2,0], [ 1,2], [1,3]]
# points_set2  = [[-1,0], [-1,2], [-3,1], [-4, 1]]

###############TO BE REMOVED##############

#######For CL records: UWB to my map##########
#points_set1 = [[0,0], [-1.43, 7.00], [-4.5, 14.07]] #For checking [[1.50,14.07], [7.43,1.00]]
#points_set2 = [[14.499, -14.9875], [7.52102, -16.444], [0.430343, -19.584]] #[[0.434477, -13.601], [13.5194, -7.54905]]
#UWB TO MY MAP TF MATRIX
#[[-0.006122284233162629, -1.0020086901252812, 14.508793651812336], [1.0020086901252812, -0.006122284233162629, -14.981530646254784], [0, 0, 1]]


#######For CL records: map to my unified##########
#Rotation_matrix:  [[0.9849706368229751, 0.06764586059785342, 6.965989211319772], [-0.06764586059785342, 0.9849706368229751, -7.516507227563957], [0, 0, 1]]
points_set1 = [[-1.19, 4.11], [4.37, 2.96], [6.55, 6.27]] #For checking [[15.0706, -6.4472], [7.36599, -6.41235]]
points_set2 = [[10.13, 5.52], [11.79, 11.14], [8.19, 12.91]] #[[20.88, 13.74], [13.17, 13.76]]

#########################################



# min 3 set of points
#points_set1 = [[4.43, 16.68], [-2.67,16.795], [2.314,1.7475], [10.85, 1.556], [0.19, 1.78], [0.21, 9.85]]
#points_set2 = [[465.41, 1596.93], [464.90,2162.43], [1640.96,1758.72], [1641.92, 1080.32], [1628.8,1952.64], [975.88,1990.62]]

trans = nudged.estimate( points_set1, points_set2 )

print(" - Rotation_matrix: ", trans.get_matrix())
print(" - Rotation (rad) : ", trans.get_rotation())
print(" - Scale Factor   : ", trans.get_scale()) 
print(" - Scale Factor   : ", trans.get_translation())

mse = nudged.estimate_error(trans, points_set1, points_set2)
print("\n estimation error: ", mse)

print(trans.transform([15.076, -6.4472]))
