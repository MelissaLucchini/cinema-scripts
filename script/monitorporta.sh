#!/bin/bash

PORT=7777

if ss -tuln | grep -q ":$PORT"; then 
    echo "Port $PORT is active." 
else 
    echo "WARNING: Port $PORT is not listening!" 
    systemctl restart sensor-service
fi