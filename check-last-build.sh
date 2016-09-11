#!/bin/bash
#Use like this: 'checkJenkins.sh <jobname>' and it will query the server with the given job name every 30s
#http://192.168.33.10:8080/job/ant-github-jenkins/lastStableBuild/buildNumber

BASE_URL=http://192.168.33.10:8080
PROJECT=$1
PROJECT_URL=/job/${PROJECT}
BUILD_STATUS_QUERY=/lastBuild/api/json
CURRENT_BUILD_NUMBER_QUERY=/lastBuild/buildNumber
LAST_STABLE_QUERY=/lastStableBuild/buildNumber

check_build()
{
    PROJECT_STATUS_JSON=`curl --silent ${BASE_URL}${PROJECT_URL}${BUILD_STATUS_QUERY}`
    CURRENT_BUILD_NUMBER=`curl --silent ${BASE_URL}${PROJECT_URL}${CURRENT_BUILD_NUMBER_QUERY}`
    LAST_STABLE=`curl --silent ${BASE_URL}${PROJECT_URL}${LAST_STABLE_QUERY}`

    GOOD_BUILD="Last build successful. "
    BAD_BUILD="Last build failed. "
    RESULT=`echo "${PROJECT_STATUS_JSON}" | sed -n 's/.*"result":\([\"A-Za-z]*\),.*/\1/p'`
    LAST_BUILD_STATUS=${GOOD_BUILD}
    echo "${LAST_STABLE}" | grep "is not available" > /dev/null
    GREP_RETURN_CODE=$?
    if [ ${GREP_RETURN_CODE} -ne 0 ]
    then
        if [ `expr ${CURRENT_BUILD_NUMBER} - 1` -gt ${LAST_STABLE} ]
        then
            LAST_BUILD_STATUS=${BAD_BUILD}
        fi
    fi

    if [ "${RESULT}" = "null" ]
    then
        echo "${LAST_BUILD_STATUS}Building ${PROJECT} ${CURRENT_BUILD_NUMBER}... last stable was ${LAST_STABLE}"
    elif [ "${RESULT}" = "\"SUCCESS\"" ]
    then
        echo "${LAST_BUILD_STATUS}${PROJECT} ${CURRENT_BUILD_NUMBER} completed successfully."
        exit 0
    elif [ "${RESULT}" = "\"FAILURE\"" ]
    then
        LAST_BUILD_STATUS=${BAD_BUILD}
        echo "${LAST_BUILD_STATUS}${PROJECT} ${CURRENT_BUILD_NUMBER} failed."
        exit 0
    else
        LAST_BUILD_STATUS=${BAD_BUILD}
        echo "${LAST_BUILD_STATUS}${PROJECT} ${CURRENT_BUILD_NUMBER} status unknown - '${RESULT}'"
    fi
}

echo "Triggering the build for $1"
curl -X POST --user saurabh:4a8ce5ad6e3330447c1edaa656e629f9 ${BASE_URL}${PROJECT_URL}/build
echo "Triggered.. Sleeping for 10 seconds before check.."
sleep 10
#echo "${CURRENT_BUILD_NUMBER}, ${LAST_STABLE}, ${RESULT}"
QUERY_TIMEOUT_SECONDS=30
while [ true ]
do
    check_build
    sleep ${QUERY_TIMEOUT_SECONDS}
done