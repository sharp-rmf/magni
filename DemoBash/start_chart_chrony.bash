#!/bin/sh
# This script will run chrony 
# Yuda

tmux has-session -t chrony
if [ $? != 0 ]; then
    # create a new session
    tmux new-session -s chrony -n chart -d

    tmux send-keys -t chrony 'sleep 10; sshpass -p chart123 ssh ubuntu@10.42.0.110' C-m
    tmux send-keys -t chrony 'sleep 0; sudo -S chronyc -a '"'burst 4/4'" C-m
    tmux send-keys -t chrony 'sleep 8; sudo -S chronyc -a makestep' C-m
    tmux select-layout tiled

fi
tmux attach -t chrony
