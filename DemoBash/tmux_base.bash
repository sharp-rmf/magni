#!/bin/sh

# modified from https://unix.stackexchange.com/questions/80473/how-do-i-run-a-shell-command-from-tmux-conf

tmux has-session -t tmux_base
if [ $? != 0 ]; then
    # create a new session
    tmux new-session -s tmux_base -n tmux_base -d
    
    # use mouse in Ubuntu 16/tmux 2.1
    tmux set -g mouse on
   
    # roscore
    tmux send-keys -t tmux_base 'ros1_melodic; roscore' C-m
    tmux select-layout tiled

    #force chrony to sync on pi, launch base node on pi
    tmux split-window -v
    tmux send-keys -t tmux_base 'sleep 5; sshpass -p chart123 ssh ubuntu@192.168.1.100' C-m
    tmux send-keys -t tmux_base 'sleep 0; sudo -S chronyc -a '"'burst 4/4'" C-m
    tmux send-keys -t tmux_base 'sleep 5; sudo -S chronyc -a makestep' C-m
    tmux send-keys -t tmux_base 'sleep 2; magni_bringup' C-m
    tmux select-layout tiled

    tmux split-window -v -t tmux_base
    tmux send-keys -t tmux_base 'ros1_melodic; sleep 10; start_rplidar_nav_stack' C-m
    tmux select-layout tiled

    # Ping
    tmux new-window -a
    tmux split-window -h -t tmux_base:2.0
    tmux send-keys 'ping 192.168.1.100' C-m

    # Rviz
    tmux new-window -a
    tmux select-window -t tmux_base:3.0
    tmux send-keys 'ros1_melodic; sleep 30; rviz -d $HOME/dev_ws/src/chart.rviz' C-m

    # Go back to the first window
    tmux select-window -t tmux_base:1.0

fi
tmux attach -t tmux_base

