#!/bin/bash

# Stop script for layerd daemon

set -e

# Check if running
if ! pgrep -x "layerd" > /dev/null; then
    echo "layerd is not running"
    exit 0
fi

echo "Stopping layerd..."
killall layerd

sleep 1

# Force kill if still running
if pgrep -x "layerd" > /dev/null; then
    echo "Force killing layerd..."
    killall -9 layerd
    sleep 1
fi

# Verify stopped
if pgrep -x "layerd" > /dev/null; then
    echo "✗ Failed to stop layerd"
    exit 1
else
    echo "✓ layerd stopped"
fi
