# magni_45 package installation
Download the .repos files

# Download the dependencies
ros-kinetic-move-base  
ros-kinetic-dwb-local-planner  
ros-kinetic-dwa-local-planner  
ros-kinetic-acml  
ros-kinetic-map-planner  
maven  

# Dependencies mentioned for Cycloneic DDS
https://github.com/eclipse-cyclonedds/cyclonedds  
C compiler (most commonly GCC on Linux, Visual Studio on Windows, Xcode on macOS);  
GIT version control system;  
CMake, version 3.7 or later;  
OpenSSL, preferably version 1.1 or later if you want to use TLS over TCP.  You can explicitly disable it by setting ENABLE_SSL=NO, which is very useful for reducing the footprint or when the FindOpenSSL CMake script gives you trouble;  
Java JDK, version 8 or later, e.g., OpenJDK;  
Apache Maven, version 3.5 or later.  
On Ubuntu apt install maven default-jdk  
python3-catkin-tools #for catkin build

# catkin build settings
```
echo 'alias magni_build="catkin build -j 1 -p 1 --mem-limit 50% --cmake-args -DBUILD_IDLC=NO' >> ~/.bashrc
cd ~/catkin_ws 
magni_build
```
