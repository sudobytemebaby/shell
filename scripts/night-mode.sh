#!/bin/bash

# Check if hyprsunset is running
if pgrep -x "hyprsunset" > /dev/null; then
  # Turn off - kill and wait for it to actually die
  killall hyprsunset
  sleep 0.1  # Give it a moment to die
  notify-send "Night Light" "Off" -u "low"
  echo "off"
else 
  # Turn on
  hyprsunset -t 5500 &
  sleep 0.1  # Give it a moment to start
  notify-send "Night Light" "On" -u "low"
  echo "on"
fi
