#!/usr/bin/env bash

# requires:
# git, maven, docker-compose, python

(git --help > /dev/null 2>&1 && echo "Git installed") || (echo "No git detected :(" && exit 1)
(mvn --help > /dev/null 2>&1 && echo "Maven installed") || (echo "No maven detected :(" && exit 1)
(docker-compose --help > /dev/null 2>&1 && echo "Docker Compose installed") || (echo "No docker-compose detected :(" && exit 1)
(python --help > /dev/null 2>&1 && echo "Python installed") || (echo "No python detected :(" && exit 1)

set -o errexit

# FUNCTIONS
function build_the_app() {
    ./mvnw clean install dependency:copy-dependencies
}

function our_docker_compose() {
    docker-compose -f "${ROOT}/docker/docker-compose.yml" "$@"
}

function docker_exec() {
    local SERVICE="$1"; shift
    our_docker_compose exec -T "$SERVICE" "$@"
}

# ${RETRIES} number of times will try to fetch the /health endpoint to passed port $1 and host $2
function fetch_health_endpoint() {
    local SERVICE="$1"
    local PORT="$2"
    local READY_FOR_TESTS=1
    for i in $( seq 1 "${RETRIES}" ); do
        sleep "${WAIT_TIME}"
        docker_exec $SERVICE wget -q -O /dev/null -T 5 "127.0.0.1:${PORT}/actuator/health" && READY_FOR_TESTS=0 && break
        echo "Fail #$i/${RETRIES}... will try again in [${WAIT_TIME}] seconds"
    done
    if [[ "${READY_FOR_TESTS}" == 1 ]] ; then
        echo "Failed to start the app..."
        kill_all
    fi
    return ${READY_FOR_TESTS}
}

# ${RETRIES} number of times will try to fetch the /health endpoint to passed port $1 and localhost
function fetch_local_health_endpoint() {
    fetch_health_endpoint $1 "127.0.0.1"
}

function send_a_test_request() {
    docker_exec frontend wget -q -O /dev/null -T 5 "127.0.0.1:8081" || return 1
    docker_exec frontend wget -q -O /dev/null -T 5 "127.0.0.1:8081" || return 1
    echo -e "\n\nSuccessfully sent two test requests!!!"
}

function run_docker() {
    our_docker_compose kill || echo "Failed to kill any docker containers"
    our_docker_compose pull
    our_docker_compose up --build -d
    our_docker_compose logs --follow zipkin > "${LOGS_DIR}/Zipkin.log" &
    our_docker_compose logs --follow frontend > "${LOGS_DIR}/Frontend.log" &
    our_docker_compose logs --follow backend > "${LOGS_DIR}/Backend.log" &
}

# kills all apps
function kill_all() {
    ${ROOT}/scripts/kill.sh
}

# Calls a GET to zipkin to dependencies
function check_trace() {
    echo -e "\nChecking if Zipkin has stored the trace"
    local STRING_TO_FIND="\"parent\":\"frontend\",\"child\":\"backend\",\"callCount\":2"
    local CURRENT_TIME=`python -c 'import time; print(int(round(time.time() * 1000)))'`
    local URL_TO_CALL="http://localhost:9411/api/v2/dependencies?endTs=$CURRENT_TIME"
    READY_FOR_TESTS="no"
    for i in $( seq 1 "${RETRIES}" ); do
        sleep "${WAIT_TIME}"
        echo -e "Sending a GET to $URL_TO_CALL . This is the response:\n"
        docker_exec zipkin wget -S -O - "$URL_TO_CALL" -T 5 | grep ${STRING_TO_FIND} && READY_FOR_TESTS="yes" && break
        echo "Fail #$i/${RETRIES}... will try again in [${WAIT_TIME}] seconds"
    done
    if [[ "${READY_FOR_TESTS}" == "yes" ]] ; then
        echo -e "\n\nSuccess! Zipkin is working fine!"
        return 0
    else
        echo -e "\n\nFailure...! Zipkin failed to store the trace!"
        return 1
    fi
}

# VARIABLES
ROOT=`pwd`
LOGS_DIR="${ROOT}/target/"
RETRIES=10
WAIT_TIME=5

mkdir -p target

cat <<'EOF'

This Bash file will try to see if a Boot app using Sleuth is working fine.
We will do the following steps to achieve this:

01) Run Zipkin, Sleuth client, and Sleuth server
02) Hit the frontend twice (GET http://localhost:8081)
03) No exceptions should take place
04) Kill all apps
05) Assert that Zipkin stored spans

_______ _________ _______  _______ _________
(  ____ \\__   __/(  ___  )(  ____ )\__   __/
| (    \/   ) (   | (   ) || (    )|   ) (
| (_____    | |   | (___) || (____)|   | |
(_____  )   | |   |  ___  ||     __)   | |
      ) |   | |   | (   ) || (\ (      | |
/\____) |   | |   | )   ( || ) \ \__   | |
\_______)   )_(   |/     \||/   \__/   )_(
EOF

if [[ "${KILL_AT_THE_END}" == "yes" ]]; then
    trap "{ kill_all; }" EXIT
fi

echo -e "\n\nRunning apps\n\n"
build_the_app

kill_all || echo -e "\n\nNothing to kill\n\n"
echo -e "\n\nRunning docker\n\n"
run_docker

echo "Waiting for Zipkin to start"
sleep 15
echo "Assuming that Zipkin is running"
fetch_health_endpoint frontend 8081
fetch_health_endpoint backend 9000
send_a_test_request
check_trace
