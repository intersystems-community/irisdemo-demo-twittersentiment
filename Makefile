
include .env

build:
	docker build -t ${DOCKER_REPOSITORY}:twittersentiment_twittersrv-version-${TAG} ./twittersrv/
	docker build -t ${DOCKER_REPOSITORY}:twittersentiment_twittersentiment-version-${TAG} ./twittersentiment/
	docker build -t ${DOCKER_REPOSITORY}:twittersentiment_callcenterdb-version-${TAG} ./callcenterdb/
	docker build -t ${DOCKER_REPOSITORY}:twittersentiment_callcenterui-version-${TAG} ./callcenterui/

clean:
	-docker rmi ${DOCKER_REPOSITORY}:twittersentiment_twittersrv-version-${TAG}
	-docker rmi ${DOCKER_REPOSITORY}:twittersentiment_twittersentiment-version-${TAG}
	-docker rmi ${DOCKER_REPOSITORY}:twittersentiment_callcenterdb-version-${TAG}
	-docker rmi ${DOCKER_REPOSITORY}:twittersentiment_callcenterui-version-${TAG}

push:
	docker push ${DOCKER_REPOSITORY}:twittersentiment_twittersrv-version-${TAG}
	docker push ${DOCKER_REPOSITORY}:twittersentiment_twittersentiment-version-${TAG}
	docker push ${DOCKER_REPOSITORY}:twittersentiment_callcenterdb-version-${TAG}
	docker push ${DOCKER_REPOSITORY}:twittersentiment_callcenterui-version-${TAG}

run:
	docker-compose up