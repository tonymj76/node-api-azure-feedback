#!/bin/bash
set -x #echo on

# Install application build dependencies...
make install

#
# Wait for DB to be ready...
#

# NOTE: Codespaces currently ignores attempts to set a custom Docker Compose project name so,
#       in the meantime, we use our own custom label.
# devContainerNameLabel=com.docker.compose.project
devContainerNameLabel=com.microsoft.vscode.dev-container-name
# TODO: Use a environment variable for the name, once Dev Containers and Codespaces deal with them consistently.
devContainerName=webapi-nodejs-dev-container
dbServiceName=db

dbContainerId=`docker ps --filter "label=$devContainerNameLabel=$devContainerName" --filter "label=com.docker.compose.service=$dbServiceName" --format "{{.ID}}"`

status=$(docker inspect --format "{{.State.Health.Status}}" "$dbContainerId")

retryCount=1
retryLimit=30

until [[ "$status" == "healthy" || $retryCount -gt $retryLimit ]]
do
    echo "Waiting for DB to become healthy ($retryCount/$retryLimit): $status"
    sleep 1
    status=$(docker inspect --format "{{.State.Health.Status}}" "$dbContainerId")
    ((retryCount++))
done

if [[ $retryCount -gt $retryLimit ]]; then
    echo Initialization failed: DB did not become healthy within the time allotted.
    exit 0
fi

#
# DB is now ready.
#

# Initialize service dependencies...
make seed_db
