#!/bin/sh
tmux new-session -d -s jtaby

tmux new-window -t jtaby:1 -n 'Abbot' ''
tmux new-window -t jtaby:2 -n 'SproutCore' ''
tmux new-window -t jtaby:3 -n 'CoreWeb' ''
tmux new-window -t jtaby:4 -n 'Me' ''
tmux new-window -t jtaby:5 -n 'Workspace' ''

tmux select-window -t jtaby:1
tmux -2 attach-session -t jtaby
