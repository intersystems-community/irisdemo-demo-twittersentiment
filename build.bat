@ECHO OFF

echo Updating sub modules...
git submodule init
git submodule update

echo BUILDING...
docker-compose stop
docker-compose rm -f

docker run --rm -it \
    -v ./callcenterui/projects:/usr/projects \
    --name mavenc intersystemsdc/irisdemo-base-mavenc:latest

docker-compose build