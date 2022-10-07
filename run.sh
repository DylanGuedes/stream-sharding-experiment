#!/bin/bash

log() {
  echo "$(date +'%H:%M:%S') $1"
}

usage() {
  echo "$0 <scenario>"
  echo ""
  echo "Arguments:"
  echo "- <scenario>:   K6 Loki test scenario definition (js file)."
}

# Parse CLI args.
if [ $# -ne 1 ]; then
  usage
  exit 1
fi

SCENARIO="$1"

# Ask confirmation before proceeding.
echo "Scenario:   ${SCENARIO}"
echo ""
read -p "Do you want to continue? (y/n) " -n 1 -r REPLY
echo ""
if [ "$REPLY" != "y" ]; then
  exit 1
fi

log "Running scenario '$SCENARIO'"
k6 run $SCENARIO

log "Finished running scenario '$SCENARIO'. Results are available under 'report.json'"