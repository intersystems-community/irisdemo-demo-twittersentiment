#!/bin/bash

exit_if_error() {
	if [ $(($(echo "${PIPESTATUS[@]}" | tr -s ' ' +))) -ne 0 ]; then
		echo ""
		echo "ERROR: $1"
		echo ""
		exit 1
	fi
}

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
			--name $1 intersystemsdc/irisdemo-base-mavenc:version-1.6.3
	fi
}