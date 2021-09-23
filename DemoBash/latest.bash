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
    tmux send-keys -t tmux_run 'ros1_melodic; sleep 8; start_nav_stack_scm_to_highway' C-m
    tmux select-layout tiled

    tmux split-window -h -t tmux_run
    #tmux send-keys -t tmux_run 'ros1_melodic; sleep 25; start_free_fleet_mb' C-m
    #tmux select-layout tiled

    # Rviz
    tmux new-window -a
    tmux select-window -t tmux_run:2.0
    tmux send-keys 'ros1_melodic; sleep 12; rviz -d $HOME/dev_ws/src/dp3.rviz' C-m

    # Ping 
    tmux new-window -a
    tmux select-window -t tmux_run:3.0
    tmux send-keys 'ros1_melodic; ping 192.168.1.100' C-m
    
    # Xnergy Charging 
    tmux new-window -a
    tmux select-window -t tmux_run:4.0
    tmux send-keys 'xnergy_start'
    tmux select-layout tiled
    tmux split-window -v
    tmux send-keys 'start_docking_vision'
    tmux select-layout tiled
    tmux split-window -v
    tmux send-keys 'start_docking_server'


    # Go back to the first window
    tmux select-window -t tmux_run:1.0

fi
tmux attach -t tmux_run

