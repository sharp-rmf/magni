#!/bin/bash
tmux has-session -t dev
if [ $? != 0 ]
then

  tmux new-session -s dev -n "dpm" -d
  tmux split-window -v -t dev:0
  
  tmux send-keys -t dev:0.0 '~/start_device.bash' C-m
  tmux send-keys -t dev:0.1 'sleep 20; ~/start_free_fleet.bash' C-m
  
  tmux new-window -n "journalctl" -t dev
  
  tmux send-keys -t dev:1.0 'journalctl -u magni-base.service -f' C-m

  tmux select-window -t dev:0

fi
tmux attach -t dev
