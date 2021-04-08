#!/bin/sh

# modified from https://unix.stackexchange.com/questions/80473/how-do-i-run-a-shell-command-from-tmux-conf

tmux has-session -t tmux_run
if [ $? != 0 ]; then
    # create a new session
    tmux new-session -s tmux_run -n tmux_run -d
    
    # use mouse in Ubuntu 16/tmux 2.1
    tmux set -g mouse on

    # Highlight active window
    tmux set-window-option -g window-status-current-bg green

    # history limit
    tmux set -g history-limit 10000

    # Set status bar
    tmux set -g status-bg black
    tmux set -g status-fg white 
    
    # to enable mouse copy/paste to system buffer
    # to copy text, go to the any window and press this sequence
    #     C-b [
    # now you are in VI mode, use the arrow keys and move to the start of text to copy
    # To select the text, press the key 'v'
    # Continue moving using the arrow keys to highlight the text to copy
    # To copy the text, press the 'y' key
    # Now your highlighted text is in system clipboard, can just use ctrl-V to paste into text editor
    # if you want to paste to another tmux buffer, press this sequence
    #     C-b ]
    tmux setw -g mode-keys vi
    tmux bind-key -t vi-copy 'v' begin-selection
    tmux bind-key -t vi-copy 'y' copy-pipe "xclip -sel clip -i"
    
    # roscore
    tmux send-keys -t tmux_run 'roscore' C-m
    tmux select-layout tiled

    #force chrony to sync on pi, launch base node on pi
    tmux split-window -v
    tmux send-keys -t tmux_run 'sleep 5; sshpass -p chart123 ssh ubuntu@192.168.1.110' C-m
    tmux send-keys -t tmux_run 'sleep 0; sudo -S chronyc -a '"'burst 4/4'" C-m
    tmux send-keys -t tmux_run 'sleep 5; sudo -S chronyc -a makestep' C-m
    tmux send-keys -t tmux_run 'sleep 2; magni_bringup' C-m
    tmux select-layout tiled

    # mobile
    tmux split-window -v -t tmux_run
    tmux send-keys -t tmux_run 'sleep 14; roslaunch sliding_autonomy start_mobile.launch robotname:=magni' C-m
    tmux select-layout tiled

    # intelligence
    tmux split-window -h -t tmux_run
    tmux send-keys -t tmux_run 'sleep 16; roslaunch sliding_autonomy start_intelligence.launch robotname:=magni' C-m
    tmux select-layout tiled

    # merge sick lasers
    tmux split-window -h -t tmux_run
    tmux send-keys -t tmux_run 'sleep 18; roslaunch /opt/ros/melodic/share/sliding_autonomy/launch/magni/merge_lidar_scan.launch' C-m
    tmux select-layout tiled

    # navigation
    tmux split-window -h -t tmux_run
    tmux send-keys -t tmux_run 'sleep 14; roslaunch sliding_autonomy start_navigation_magni.launch yaml_map:=cafe_level_1 robotname:=magni ' C-m
    tmux select-layout tiled

    # line following
    tmux split-window -h -t tmux_run
    tmux send-keys -t tmux_run 'sleep 14; roslaunch task_handler_line_following start.launch robotname:=magni' C-m
    tmux select-layout tiled

    # line following
    # tmux split-window -h -t tmux_run
    # tmux send-keys -t tmux_run 'sleep 12; roslaunch task_handler_pursuit start.launch robotname:=sml' C-m
    # tmux select-layout tiled
    

fi
tmux attach -t tmux_run

