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

# Ensure the logs directory exists
mkdir -p ./logs

# Write the executed command to the log file
echo "Executed command: $@" > "$log_file"
echo "===============================" >> "$log_file"

# Run the command, redirect output to the log file, and also display it in the terminal
"$@" > >(tee -a "$log_file") 2> >(tee -a "$log_file" >&2)

# Notify the user
echo "Command output saved to $log_file"
