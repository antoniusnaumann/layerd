#!/bin/bash

# Start script for layerd daemon

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LOG_FILE="${LOG_FILE:-/tmp/layerd.log}"

cd "$SCRIPT_DIR"

# Check if already running
if pgrep -x "layerd" > /dev/null; then
    echo "layerd is already running"
    echo "Run './stop.sh' to stop it first"
    exit 1
fi

# Build if needed
if [ ! -f "zig-out/bin/layerd" ]; then
    echo "Building layerd..."
    zig build
fi

# Start daemon
echo "Starting layerd..."
./zig-out/bin/layerd > "$LOG_FILE" 2>&1 &

sleep 1

# Check if it started successfully
if pgrep -x "layerd" > /dev/null; then
    echo "✓ layerd started successfully"
    echo "  Logs: $LOG_FILE"
    echo "  Monitor: tail -f $LOG_FILE"
    echo "  Stop: ./stop.sh"
else
    echo "✗ Failed to start layerd"
    echo "Check logs: cat $LOG_FILE"
    exit 1
fi
