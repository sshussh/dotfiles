#!/usr/bin/env bash

# Reload kitty terminal with proper error handling and output suppression

# Check if kitty is running
if ! pgrep -x kitty > /dev/null 2>&1; then
    echo "Error: kitty is not running" >&2
    exit 1
fi

# Check if we're running inside kitty
if [ -z "$KITTY_PID" ]; then
    echo "Warning: Not running inside kitty terminal" >&2
fi

# Attempt to reload kitty configuration
if command -v kitty > /dev/null 2>&1; then
    # Send reload signal to all kitty instances
    killall -SIGUSR1 kitty > /dev/null 2>&1

    # Alternative method using kitty remote control if available
    if [ -n "$KITTY_LISTEN_ON" ] || [ -n "$KITTY_PID" ]; then
        kitty @ load-config > /dev/null 2>&1 || true
    fi
else
    echo "Error: kitty command not found" >&2
    exit 1
fi

exit 0
