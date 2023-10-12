#!/bin/bash
set -eo pipefail

# Function to Clean up testing artifacts
function finish {
  echo "******************************"
  echo "Cleaning up testing artifacts"
  echo "******************************"
  docker stop $runid $cid
  docker rm -vf $runid $cid
  docker network rm test-network
}

# Remove container afterwards
trap finish EXIT

[ "$DEBUG" ] && set -x

# Set current working directory
cd "$(dirname "$0")"

dockerImage=$1

if ! docker inspect "$dockerImage" &> /dev/null; then
    echo $'\timage does not exist!'
    false
fi

# Create an instance of the container-under-test
cid="$(docker run -d "$dockerImage")"

#Run Tests
pwd=/app
TEST_PWD="$(docker exec "$cid" pwd )"
[ "$TEST_PWD" == "$pwd" ] || (echo "Incorrect pwd $TEST_PWD it should be $pwd" && exit 1)

# Is the  Application directory there
#[ $(docker exec $cid ls basin3d_app 2>&1 | grep 'cannot' | wc -l) -ne 1  ] || \
#    (echo "Application missing" && exit 1)

# Give time to start up
sleep 5

#Check for added catalina properties
[ $(docker exec $cid ls -l /app/manage.py | grep '^-rwxr-xr-x' | wc -l) -ne 0 ] || (echo "Django manage.py missing" && exit 1)


# Test the full application
docker network create test-network > /dev/null


runid=$(docker run  \
       -p 5555:8080    \
       -e ADMIN_PASSWORD=foobar \
       -d \
       --network=test-network  \
       -it $dockerImage)


# Waiting for startup
sleep 20

[ $(docker logs $runid | grep 'static files copied to ' | wc -l) -ne 0 ] || \
    (echo "FAIL: Static files not not collected!" && exit 1)

[ $(docker logs $runid | grep 'Running migrations:' | wc -l) -ne 0 ] || \
    (echo "FAIL: Migrations not run" && exit 1)

[ $(docker logs $runid | grep 'IS_LOADED:0' | wc -l) -ne 0 ] || \
    (echo "FAIL: Database is not empty" && exit 1)

[ $(curl -s -o /dev/null -w "%{http_code}" http://localhost:5555  ) == "200" ] || \
   (echo "FAIL: Invalid HTTP Status Code" && exit 1)

[ $(curl -s http://localhost:5555   | grep 'datasources' | wc -l ) -ne 0 ] || \
   (echo "FAIL: Invalid return value" && exit 1)

echo "**********"
echo "SUCCESS!!"
echo "**********"