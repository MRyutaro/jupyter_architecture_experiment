#!/bin/bash

# Check if a command is provided
if [ "$#" -lt 1 ]; then
    echo "Usage: $0 <command>"
    exit 1
fi

# Get the current timestamp
timestamp=$(date +%Y%m%d_%H%M%S)

# Construct the log file name
log_file="./logs/${timestamp}.log"

# Run the command and redirect output to the log file
"$@" > "$log_file" 2>&1

# Notify the user
echo "Command output saved to $log_file"
