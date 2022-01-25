#!/bin/bash

DOCKER_REPO=intersystemsdc/irisdemo-demo-twittersentiment
VERSION=`cat ./VERSION`

source ./buildtools.sh

docker-compose stop
docker-compose rm -f

echo
echo "### HOOK - building twittersrv..."
docker build -t ${DOCKER_REPO}:twittersrv-version-${VERSION} ./twittersrv/
exit_if_error "Could not build ./twittersrv"

echo
echo "### HOOK - building twittersentiment..."
docker build -t ${DOCKER_REPO}:twittersentiment-version-${VERSION} ./twittersentiment/
exit_if_error "Could not build ./twittersentiment"

echo
echo "### HOOK - building callcenterdb..."
docker build -t ${DOCKER_REPO}:callcenterdb-version-${VERSION} ./callcenterdb/
exit_if_error "Could not build ./callcenterdb"

echo
echo "### HOOK - building callcenterui..."
# Compiling source codes to generare war file.
build_java_project "callcenterui"
# docker run --rm \
#     -v $PWD/callcenterui/projects:/usr/projects \
#     --name mavenc intersystemsdc/irisdemo-base-mavenc:latest

docker build -t ${DOCKER_REPO}:callcenterui-version-${VERSION} ./callcenterui/
exit_if_error "Could not build ./callcenterui"