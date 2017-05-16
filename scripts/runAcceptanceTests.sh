#!/usr/bin/env bash

# requires:
# git, maven

(git --help > /dev/null 2>&1 && echo "Git installed") || (echo "No git detected :(" && exit 1)
(mvn --help > /dev/null 2>&1 && echo "Maven installed") || (echo "No maven detected :(" && exit 1)

set -e

# FUNCTIONS
function build_the_app() {
  ./mvnw clean install ${ENV_VARS}
}

function run_maven_exec() {
  local CLASS_NAME=$1
  local EXPRESSION="nohup ./mvnw exec:java -Dexec.mainClass=sleuth.webmvc.${CLASS_NAME} ${ENV_VARS} >${LOGS_DIR}/${CLASS_NAME}.log &"
  echo -e "\n\nTrying to run [$EXPRESSION]"
  eval ${EXPRESSION}
  pid=$!
  echo ${pid} > ${LOGS_DIR}/${CLASS_NAME}.pid
  echo -e "[${CLASS_NAME}] process pid is [${pid}]"
  echo -e "Logs are under [${LOGS_DIR}${CLASS_NAME}.log]\n"
  return 0
}

# ${RETRIES} number of times will try to curl to /health endpoint to passed port $1 and host $2
function curl_health_endpoint() {
    local PORT=$1
    local PASSED_HOST="${2:-$HEALTH_HOST}"
    local READY_FOR_TESTS=1
    for i in $( seq 1 "${RETRIES}" ); do
        sleep "${WAIT_TIME}"
        curl -m 5 "${PASSED_HOST}:${PORT}/health" && READY_FOR_TESTS=0 && break
        echo "Fail #$i/${RETRIES}... will try again in [${WAIT_TIME}] seconds"
    done
    if [[ "${READY_FOR_TESTS}" == 1 ]] ; then
        echo "Failed to start the app..."
        kill_all
    fi
    return ${READY_FOR_TESTS}
}

# ${RETRIES} number of times will try to curl to /health endpoint to passed port $1 and localhost
function curl_local_health_endpoint() {
    curl_health_endpoint $1 "127.0.0.1"
}

function send_a_test_request() {
    curl -m 5 "127.0.0.1:8081" && curl -m 5 "127.0.0.1:8081" && echo -e "\n\nSuccessfully sent two test requests!!!"
}

# kills all apps
function kill_all() {
    ${ROOT}/scripts/kill.sh
}

# VARIABLES
ROOT=`pwd`
LOGS_DIR="${ROOT}/target/"
HEALTH_HOST="127.0.0.1"
RETRIES=10
WAIT_TIME=5
ENV_VARS=${ENV_VARS:--Dsleuth.version=1.1.5.BUILD-SNAPSHOT}

mkdir -p target

cat <<'EOF'

This Bash file will try to see if a Boot app using Sleuth is working fine.
We will do the following steps to achieve this:

01) Run Sleuth client
02) Wait for it to start
03) Run Sleuth server
04) Wait for it to start
05) Hit the frontend twice (GET http://localhost:8081)
06) No exceptions should take place
07) Kill all apps

_______ _________ _______  _______ _________
(  ____ \\__   __/(  ___  )(  ____ )\__   __/
| (    \/   ) (   | (   ) || (    )|   ) (
| (_____    | |   | (___) || (____)|   | |
(_____  )   | |   |  ___  ||     __)   | |
      ) |   | |   | (   ) || (\ (      | |
/\____) |   | |   | )   ( || ) \ \__   | |
\_______)   )_(   |/     \||/   \__/   )_(
EOF

echo -e "\n\nRunning apps\n\n"
build_the_app
run_maven_exec "Frontend"
curl_local_health_endpoint 8081
run_maven_exec "Backend"
curl_local_health_endpoint 9000
send_a_test_request
kill_all
