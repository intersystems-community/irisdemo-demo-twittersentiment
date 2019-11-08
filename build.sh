#!/bin/bash

set -e

printf "\nUpdating sub modules...\n"
git submodule init
git submodule update

docker-compose stop
docker-compose rm -f

docker run --rm -it \
    -v ./callcenterui/projects:/usr/projects \
    --name mavenc intersystemsdc/irisdemo-base-mavenc:latest

docker-compose build