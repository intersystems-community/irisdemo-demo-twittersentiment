#!/bin/bash

DOCKER_REPO=intersystemsdc/irisdemo-demo-twittersentiment
VERSION=`cat ./VERSION`

build_java_project() {
	[[ -z "${1}" ]] && echo "Environment variable $1 not set. Need name of the java project to build." && exit 1

	rm ${PWD}/$1/projects/app.war

	docker ps -a | grep $1 > /dev/null
	if [ $? -eq 0 ]; then
		# This will reuse the mavenc container that we used previously to compile the project
		# This way, we avoid redownloading all the depedencies!
        echo "Reusing container $1 to recompile jar..."
		docker start -i $1
	else
		# First tiem trying to compile a project, let's create the mavenc container
		# It will download all the dependencies of the project
        echo "Creating container $1 to recompile jar..."
		docker run -it \
			-v ${PWD}/$1/projects:/usr/projects \
			--name $1 intersystemsdc/irisdemo-base-mavenc:latest
	fi
}

docker-compose stop
docker-compose rm -f

echo
echo "### HOOK - building twittersrv..."
docker build -t ${DOCKER_REPO}:twittersrv-version-${VERSION} ./twittersrv/

echo
echo "### HOOK - building twittersentiment..."
docker build -t ${DOCKER_REPO}:twittersentiment-version-${VERSION} ./twittersentiment/

echo
echo "### HOOK - building callcenterdb..."
docker build -t ${DOCKER_REPO}:callcenterdb-version-${VERSION} ./callcenterdb/

echo
echo "### HOOK - building callcenterui..."
# Compiling source codes to generare war file.
build_java_project "callcenterui"
# docker run --rm \
#     -v $PWD/callcenterui/projects:/usr/projects \
#     --name mavenc intersystemsdc/irisdemo-base-mavenc:latest

docker build -t ${DOCKER_REPO}:callcenterui-version-${VERSION} ./callcenterui/