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

readiness-check() {
  while [[ "$(curl -s -o /dev/null -m 3 -L -w ''%{http_code}'' ${1})" != "200" ]];\
  do
    log "Waiting for ${1}" && sleep 2;\
  done
  log "${1} passed readiness check"
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

log "Running experiment for scenario '$SCENARIO'"

### Boot cluster A
cd ./scenario_a/cluster_a
docker-compose up -d
cd ../../
readiness-check http://localhost:3101/ready
log "cluster A is ready, starting experiment"

### Run experiment against cluster A
K6_PROMETHEUS_REMOTE_URL=http://localhost:9090/api/v1/write \
k6 run $SCENARIO/cluster_a/scenario.js \
-o output-prometheus-remote

log "Finished running scenario '$SCENARIO'"