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

################################################################################
#  CLUSTER A
## Boot cluster A
cd ./$SCENARIO/cluster_a
docker-compose up -d
cd ../../
readiness-check http://localhost:3101/ready
log "cluster A is ready, starting experiment"

### Run experiment against cluster A
K6_PROMETHEUS_REMOTE_URL=http://localhost:9090/api/v1/write \
k6 run $SCENARIO/cluster_a/scenario.js \
-o output-prometheus-remote
log "Finished running experiment against cluster A"
log "Sleeping for 30s to scrape final metrics"
sleep 30
log "Stopping cluster A"
cd ./$SCENARIO/cluster_a
docker-compose stop
cd ../../
###############################################################################

###############################################################################
#   CLUSTER B
### Boot cluster B
cd ./$SCENARIO/cluster_b
docker-compose up -d
cd ../../
readiness-check http://localhost:3101/ready
log "cluster B is ready, starting experiment"

### Run experiment against cluster B
K6_PROMETHEUS_REMOTE_URL=http://localhost:9090/api/v1/write \
k6 run $SCENARIO/cluster_b/scenario.js \
-o output-prometheus-remote
log "Finished running experiment against cluster B"
log "Sleeping for 30s to scrape final metrics"
sleep 30
log "Stopping cluster B"
cd ./$SCENARIO/cluster_b
docker-compose stop
cd ../../
###############################################################################

###############################################################################
#   CLUSTER C
### Boot cluster C
cd ./$SCENARIO/cluster_c
docker-compose up -d
cd ../../
readiness-check http://localhost:3101/ready
log "cluster C is ready, starting experiment"

### Run experiment against cluster C
K6_PROMETHEUS_REMOTE_URL=http://localhost:9090/api/v1/write \
k6 run $SCENARIO/cluster_c/scenario.js \
-o output-prometheus-remote
log "Finished running experiment against cluster C"
log "Sleeping for 30s to scrape final metrics"
sleep 30
log "Stopping cluster C"
cd ./$SCENARIO/cluster_c
docker-compose stop
cd ../../

# ###############################################################################
# #   CLUSTER D
# ### Boot cluster D
# cd ./$SCENARIO/cluster_d
# docker-compose up -d
# cd ../../
# readiness-check http://localhost:3101/ready
# log "cluster D is ready, starting experiment"

# ### Run experiment against cluster D
# K6_PROMETHEUS_REMOTE_URL=http://localhost:9090/api/v1/write \
# k6 run $SCENARIO/cluster_d/scenario.js \
# -o output-prometheus-remote
# log "Finished running experiment against cluster D"
# log "Sleeping for 30s to scrape final metrics"
# sleep 30
# log "Stopping cluster D"
# cd ./$SCENARIO/cluster_d
# docker-compose stop
# cd ../../
# ###############################################################################

log "Finished running scenario '$SCENARIO'"
