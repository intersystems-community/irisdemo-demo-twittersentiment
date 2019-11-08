@ECHO OFF

echo RUNNING...
docker-compose stop
docker-compose rm -f
docker-compose up