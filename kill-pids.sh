#!/bin/bash

# Example CLI usage:
# .~/util-scripts/kill-pids.sh '<tool> <module/lib>'

# Colors!
GREEN='\033[0;32m'
NC='\033[0m' # No Color
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
RED='\033[0;31m'

# Function to display usage
usage() {
  echo "Usage: $0 <process_pattern>"
  echo "Example: $0 firefox"
  echo "Example: $0 'python.*server'"
  exit 1
}

# Check if argument is provided
if [ $# -eq 0 ]; then
  echo "Error: No process pattern provided"
  usage
fi

PATTERN="$1"

echo "Searching for processes matching pattern: '$PATTERN'"
echo "----------------------------------------"

# Get processes matching the pattern, excluding grep itself and this script
PROCESSES=$(ps aux | grep "$PATTERN" | grep -v grep | grep -v "$0")

if [ -z "$PROCESSES" ]; then
  echo "No processes found matching pattern '$PATTERN'"
  exit 0
fi

echo "Found the following processes:"
echo "$PROCESSES"
echo "----------------------------------------"

# Extract PIDs
PIDS=$(echo "$PROCESSES" | awk '{print $2}')
PID_COUNT=$(echo "$PIDS" | wc -w)

echo "Process IDs to be killed: $PIDS"
echo "Total processes: $PID_COUNT"
echo

# Ask for confirmation
echo -e "${RED}WARNING: This will terminate the processes listed above!${NC}"
read -p "$(echo -e "${YELLOW}Do you want to kill these processes? (y/N): ${NC}")" -n 1 -r
echo

if [[ $REPLY =~ ^[Yy]$ ]]; then
  print_step "Killing processes"

  for pid in $PIDS; do
    if kill -0 "$pid" 2>/dev/null; then
      echo -e "${BLUE}Attempting to kill process ${YELLOW}$pid${BLUE}...${NC}"
      if kill "$pid" 2>/dev/null; then
        echo -e "${GREEN} "Killed process $pid"${NC}"
      else
        echo -e "${RED}Failed to kill process $pid (trying SIGKILL...)${NC}"
        if kill -9 "$pid" 2>/dev/null; then
          echo -e "${YELLOW} Force-killed process $pid ${NC}"
        else
          echo -e "${YELLOW}Failed to force-kill process $pid${NC}"
        fi
      fi
    else
      echo -e "${GREEN}Process $pid no longer exists${NC}"
    fi
  done

  echo -e "${GREEN}Operation completed!${NC}"
else
  echo -e "${RED}Operation cancelled${NC}"
  exit 0
fi
