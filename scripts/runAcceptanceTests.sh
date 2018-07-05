#!/usr/bin/env bash

# requires:
# git, docker-compose, python

set -o errexit

(git --help > /dev/null 2>&1 && echo "Git installed") || (echo "No git detected :(" && exit 1)
(docker-compose --help > /dev/null 2>&1 && echo "Docker Compose installed") || (echo "No docker-compose detected :(" && exit 1)
(python --help > /dev/null 2>&1 && echo "Python installed") || (echo "No python detected :(" && exit 1)


# FUNCTIONS
function build_the_app() {
  ./mvnw clean install ${ENV_VARS}
}

function run_maven_exec() {
  local CLASS_NAME=$1
  local EXPRESSION="nohup ./mvnw exec:java -Dexec.mainClass=sleuth.webmvc.${CLASS_NAME} ${ENV_VARS} -Dlogging.level.org.springframework.cloud.sleuth=DEBUG >${LOGS_DIR}/${CLASS_NAME}.log &"
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
        curl --fail -m 5 "${PASSED_HOST}:${PORT}/actuator/health" && READY_FOR_TESTS=0 && break
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
    curl --fail -m 5 "127.0.0.1:8081" && curl --fail -m 5 "127.0.0.1:8081" && echo -e "\n\nSuccessfully sent two test requests!!!"
}

function send_a_test_request_to_message() {
    curl --fail -m 5 "127.0.0.1:8081/message" && echo -e "\n\nSuccessfully triggered a message!!! Now will wait for 5 seconds for Frontend to get it..." && sleep 5
}

function run_docker() {
    docker-compose -f "${ROOT}/docker/docker-compose.yml" kill || echo "Failed to kill any docker containers"
    docker-compose -f "${ROOT}/docker/docker-compose.yml" pull
    docker-compose -f "${ROOT}/docker/docker-compose.yml" up -d rabbitmq
    sleep 5
    docker-compose -f "${ROOT}/docker/docker-compose.yml" up -d zipkin
}

# kills all apps
function kill_all() {
    ${ROOT}/scripts/kill.sh
}

# Calls a GET to zipkin to dependencies
function check_trace() {
    echo -e "\nChecking if Zipkin has stored the trace"
    local STRING_TO_FIND="\"parent\":\"frontend\",\"child\":\"rabbitmq\",\"callCount\":1},{\"parent\":\"rabbitmq\",\"child\":\"backend\",\"callCount\":1},{\"parent\":\"frontend\",\"child\":\"backend\",\"callCount\":2"
    local CURRENT_TIME=`python -c 'import time; print int(round(time.time() * 1000))'`
    local URL_TO_CALL="http://localhost:9411/api/v2/dependencies?endTs=$CURRENT_TIME"
    READY_FOR_TESTS="no"
    for i in $( seq 1 "${RETRIES}" ); do
        sleep "${WAIT_TIME}"
        echo -e "Sending a GET to $URL_TO_CALL . This is the response:\n"
        curl -sS --fail "$URL_TO_CALL" | grep ${STRING_TO_FIND} &&  READY_FOR_TESTS="yes" && break
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

# The function uses Maven Wrapper - if you're using Maven you have to have it on your classpath
# and change this function
function extractMavenProperty() {
	local prop="${1}"
	MAVEN_PROPERTY=$(./mvnw -q  \
 -Dexec.executable="echo"  \
 -Dexec.args="\${${prop}}"  \
 --non-recursive  \
 org.codehaus.mojo:exec-maven-plugin:1.3.1:exec)
	# In some spring cloud projects there is info about deactivating some stuff
	MAVEN_PROPERTY=$(echo "${MAVEN_PROPERTY}" | tail -1)
	# In Maven if there is no property it prints out ${propname}
	if [[ "${MAVEN_PROPERTY}" == "\${${prop}}" ]]; then
		echo ""
	else
		echo "${MAVEN_PROPERTY}"
	fi
}

# VARIABLES
ROOT=`pwd`
LOGS_DIR="${ROOT}/target/"
HEALTH_HOST="127.0.0.1"
RETRIES=10
WAIT_TIME=5
CURRENT_SLEUTH_VERSION=$( extractMavenProperty "sleuth.version" )
echo "Current Sleuth Version is [${CURRENT_SLEUTH_VERSION}]"
NEW_SLEUTH_VERSION="${CURRENT_SLEUTH_VERSION%.*}.BUILD-SNAPSHOT"
echo "New Sleuth Version is [${NEW_SLEUTH_VERSION}]"
ENV_VARS=${ENV_VARS:--Dsleuth.version=${NEW_SLEUTH_VERSION}}
echo "Will run the build with env vars [${ENV_VARS}]"

mkdir -p target

cat <<'EOF'

This Bash file will try to see if a Boot app using Sleuth is working fine.
We will do the following steps to achieve this:

01) Run Sleuth client
02) Wait for it to start
03) Run Sleuth server
04) Wait for it to start
05) Hit the frontend twice (GET http://localhost:8081)
06) Hit the frontend to /message endpoint to trigger a message (GET http://localhost:8081/message)
07) No exceptions should take place
08) Kill all apps
09) Assert that Zipkin stored spans (2 x HTTP and 2 x messaging)

_______ _________ _______  _______ _________
(  ____ \\__   __/(  ___  )(  ____ )\__   __/
| (    \/   ) (   | (   ) || (    )|   ) (
| (_____    | |   | (___) || (____)|   | |
(_____  )   | |   |  ___  ||     __)   | |
      ) |   | |   | (   ) || (\ (      | |
/\____) |   | |   | )   ( || ) \ \__   | |
\_______)   )_(   |/     \||/   \__/   )_(
EOF

kill_all || echo -e "\n\nNothing to kill\n\n"
echo -e "\n\nRunning docker\n\n"
run_docker

if [[ "${KILL_AT_THE_END}" == "yes" ]]; then
    trap "{ kill_all; }" EXIT
fi

echo -e "\n\nRunning apps\n\n"
build_the_app
run_maven_exec "Frontend"
curl_local_health_endpoint 8081
run_maven_exec "Backend"
curl_local_health_endpoint 9000
send_a_test_request
send_a_test_request_to_message
check_trace
