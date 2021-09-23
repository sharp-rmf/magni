#!/bin/sh

# modified from https://unix.stackexchange.com/questions/80473/how-do-i-run-a-shell-command-from-tmux-conf

tmux has-session -t tmux_run
if [ $? != 0 ]; then
    # create a new session
    tmux new-session -s tmux_run -n tmux_run -d
    
    # use mouse in Ubuntu 16/tmux 2.1
    tmux set -g mouse on

    # tmux setw -g mode-keys vi
    # tmux bind-key -t vi-copy 'v' begin-selection
    # tmux bind-key -t vi-copy 'y' copy-pipe "xclip -sel clip -i"
    
    # roscore
    tmux send-keys -t tmux_run 'ros1_melodic; roscore' C-m
    tmux select-layout tiled

    #force chrony to sync on pi, launch base node on pi
    tmux split-window -v
    tmux send-keys -t tmux_run 'sleep 5; sshpass -p chart123 ssh ubuntu@192.168.1.100' C-m
    tmux send-keys -t tmux_run 'sleep 0; sudo -S chronyc -a '"'burst 4/4'" C-m
    tmux send-keys -t tmux_run 'sleep 5; sudo -S chronyc -a makestep' C-m
    tmux send-keys -t tmux_run 'sleep 2; magni_bringup' C-m
    tmux select-layout tiled

    tmux split-window -v -t tmux_run
    tmux send-keys -t tmux_run 'ros1_melodic; sleep 10; start_rplidar_nav_stack'
    tmux select-layout tiled

    tmux split-window -h -t tmux_run
    tmux send-keys -t tmux_run 'ros1_melodic; sleep 10; start_free_fleet'
    tmux select-layout tiled

    # Ping 
    tmux new-window -a
    tmux select-window -t tmux_run:2.0
    tmux send-keys 'ping 10.11.12.1' C-m
    tmux split-window -h -t tmux_run:2.0
    tmux send-keys 'ping 192.168.1.100' C-m

    # Rviz
    tmux new-window -a
    tmux select-window -t tmux_run:3.0
    tmux send-keys 'ros1_melodic; sleep 30; rviz -d $HOME/dev_ws/src/tall.rviz' C-m

    # Compartment
    tmux new-window -a
    tmux select-window -t tmux_run:4.0
    tmux send-keys 'ros2_eloquent; source $HOME/ros2_compartment_ws/install/setup.bash; ros2 run magni_compartment compartment_node' C-m
    tmux split-window -v -t tmux_run:4.0
    tmux send-keys 'sleep 5; ros2_eloquent; source $HOME/ros2_compartment_ws/install/setup.bash; python3 $HOME/ros2_compartment_ws/src/magni_compartment/gui/scripts/dpm_node.py' C-m

    #For the face and voice
    tmux new-window -a
    tmux select-window -t tmux_run:5.0
    tmux send-keys 'ros1_melodic; source ~/homer_ws/devel/setup.bash; roslaunch homer_robot_face robot_with_voice.launch'
    tmux split-window -v -t tmux_run:5.0 
    tmux send-keys 'ros1_melodic; source ~/homer_ws/devel/setup.bash; rosrun homer_dpm homer_loop.py' 

    # Go back to the first window
    tmux select-window -t tmux_run:1.0

fi
tmux attach -t tmux_run

