#!/usr/bin/env bash

set -e

if [ -z $1 ] ;
  then
    echo "Usage: $0 <django-basin3d-tag> (<uid> <gid>)"
    exit
fi

PYTHON_VERSION=3.8
BUILD_ARGS="--build-arg PYTHON_VERSION=${PYTHON_VERSION}"
BUILD_ARGS="${BUILD_ARGS} --build-arg DJANGO_BASIN3D_VERSION=$1"
if [ ! -z $2 ] ;
then
    IMAGE_UID=$2
fi

if [ ! -z $3 ] ;
then
    IMAGE_GID=$3
fi

if [ ! -z $IMAGE_UID ];
then
  BUILD_ARGS="${BUILD_ARGS} --build-arg IMAGE_UID=$IMAGE_UID"
fi

if [ ! -z $IMAGE_GID ];
then
  BUILD_ARGS="${BUILD_ARGS} --build-arg IMAGE_GID=$IMAGE_GID"
fi


DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"
TAG=$1


echo "************************************"
echo " Checking for a new python image "
echo "************************************"
docker pull python:$PYTHON_VERSION

DOCKER_TAG="${TAG}-p$(git rev-list HEAD --count)"
# CREATE image_version.yml
echo "****************************"
echo "BUILDING image_version"
echo "****************************"
git log -n 1 --pretty="commit_count:  $(git rev-list HEAD --count)%ncommit_hash:   %h%nsubject:       %s%ncommitter:     %cN <%ce>%ncommiter_date: %ci%nauthor:        %aN <%ae>%nauthor_date:   %ai%nref_names:     %D" > image_version.yml
cat image_version.yml


# Determine if there is an image
IMAGE_NAME="django-basin3d:${DOCKER_TAG}"
if [ "${REGISTRY}" != "" ];
then
  # There is a  registry
  IMAGE_NAME="${REGISTRY}/${IMAGE_NAME}"
fi

echo "docker build ${DOCKER_BUILD_OPTIONS} -t ${IMAGE_NAME} $BUILD_ARGS ."
docker build ${DOCKER_BUILD_OPTIONS}  -t ${IMAGE_NAME} $BUILD_ARGS .

