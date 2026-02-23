#!/bin/bash

ERROR_LOG="/var/log/nginx/error.log" 
THRESHOLD=5

ERROR_COUNT=$(grep -E "500|502" "$ERROR_LOG" | wc -l)

if [ "$ERROR_COUNT" -gt "$THRESHOLD" ]; then e
    cho "ALERT: High number of server errors detected."

fi