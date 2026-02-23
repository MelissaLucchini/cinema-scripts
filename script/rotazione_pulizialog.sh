#!/bin/bash

LOG_FILE="/var/log/cinema/sensors.log" 

MAX_SIZE=5000000 # 5MB

FILE_SIZE=$(stat -c%s "$LOG_FILE")

if [ "$FILE_SIZE" -ge "$MAX_SIZE" ]; then 

    TIMESTAMP=$(date +%Y-%m-%d) 
    tar -czf "sensors_$TIMESTAMP.tar.gz" "$LOG_FILE" 
    > "$LOG_FILE" 

    echo "Log rotated successfully."
fi