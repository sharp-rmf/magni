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
    
    # roscore
    tmux send-keys -t tmux_run 'source /opt/ros/melodic/setup.bash && roscore' C-m
    tmux select-layout tiled

    #force chrony to sync on pi, launch base node on pi
    tmux split-window -v
    tmux send-keys -t tmux_run 'sleep 5; sshpass -p chart123 ssh ubuntu@192.168.1.100' C-m
    tmux send-keys -t tmux_run 'sleep 0; sudo -S chronyc -a '"'burst 4/4'" C-m
    tmux send-keys -t tmux_run 'sleep 5; sudo -S chronyc -a makestep' C-m
    tmux send-keys -t tmux_run 'sleep 2; magni_bringup' C-m
    tmux select-layout tiled

    # nav stack
    tmux split-window -v -t tmux_run
    tmux send-keys -t tmux_run ' sleep 10 && roslaunch magni rspearl_act.launch' C-m
    tmux select-layout tiled

    tmux split-window -h -t tmux_run
    tmux send-keys -t tmux_run 'sleep 10 && rviz -d ~/magni_ws/src/magni/magni/test/act.rviz' C-m
    tmux select-layout tiled
fi
tmux attach -t tmux_run
