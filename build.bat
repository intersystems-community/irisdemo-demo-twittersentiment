@ECHO OFF

SET DOCKER_REPO=intersystemsdc/irisdemo-demo-twittersentiment
set /p VERSION=<VERSION
set PWD=%~dp0

echo BUILDING...
docker-compose stop
docker-compose rm -f

echo
echo "### HOOK - building twittersrv..."
docker build -t %DOCKER_REPO%:twittersrv-version-%VERSION% ./twittersrv/

echo
echo "### HOOK - building twittersentiment..."
docker build -t %DOCKER_REPO%:twittersentiment-version-%VERSION% ./twittersentiment/

echo
echo "### HOOK - building callcenterdb..."
docker build -t %DOCKER_REPO%:callcenterdb-version-%VERSION% ./callcenterdb/

echo
echo "### HOOK - building callcenterui..."
# Compiling source codes to generare war file.
docker run --rm \
    -v %PWD%\callcenterui\projects:/usr/projects \
    --name mavenc intersystemsdc/irisdemo-base-mavenc:latest

docker build -t %DOCKER_REPO%:callcenterui-version-%VERSION% ./callcenterui/