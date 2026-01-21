#!/bin/bash
PID_FILE="/tmp/wl-recorder.pid"
RECORD_DIR="$HOME/Videos/Recordings"
mkdir -p "$RECORD_DIR"

if [ -f "$PID_FILE" ]; then
    # Stop recording
    PID=$(cat "$PID_FILE")
    kill -INT "$PID" 2>/dev/null
    rm "$PID_FILE"
    notify-send -u normal "Screen Recording" "Recording stopped and saved!" -i media-record
else
    # Start recording (properly detached)
    FILENAME="$RECORD_DIR/recording_$(date +%Y%m%d_%H%M%S).mkv"
    
    # Using wl-screenrec with MKV container (more robust)
    nohup wl-screenrec --filename "$FILENAME" > /dev/null 2>&1 &
    echo $! > "$PID_FILE"
    
    # Disown the process so it's completely independent
    disown
    
    notify-send -u normal "Screen Recording" "Recording started..." -i media-record
fi
