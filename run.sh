#!/bin/bash

printf "\n\nStopping and deleting previous containers...\n"
docker-compose stop
docker-compose rm -f
docker-compose up