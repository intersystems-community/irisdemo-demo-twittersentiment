
include .env

build:
	docker build -t ${DOCKER_REPOSITORY}:twittersrv-version-${TAG} ./twittersrv/
	docker build -t ${DOCKER_REPOSITORY}:twittersentiment-version-${TAG} ./twittersentiment/
	docker build -t ${DOCKER_REPOSITORY}:callcenterdb-version-${TAG} ./callcenterdb/

	# Compiling source codes to generare war file.
	docker run --rm -it \
		-v ${PWD}/callcenterui/projects:/usr/projects \
		--name mavenc intersystemsdc/irisdemo-base-mavenc:version-latest

	docker build -t ${DOCKER_REPOSITORY}:callcenterui-version-${TAG} ./callcenterui/

clean:
	-docker rmi ${DOCKER_REPOSITORY}:twittersrv-version-${TAG}
	-docker rmi ${DOCKER_REPOSITORY}:twittersentiment-version-${TAG}
	-docker rmi ${DOCKER_REPOSITORY}:callcenterdb-version-${TAG}
	-docker rmi ${DOCKER_REPOSITORY}:callcenterui-version-${TAG}

push:
	docker push ${DOCKER_REPOSITORY}:twittersrv-version-${TAG}
	docker push ${DOCKER_REPOSITORY}:twittersentiment-version-${TAG}
	docker push ${DOCKER_REPOSITORY}:callcenterdb-version-${TAG}
	docker push ${DOCKER_REPOSITORY}:callcenterui-version-${TAG}

run:
	docker-compose up