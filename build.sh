#!/bin/bash

set -e

CONTAINER='intentmedia/vertica-snapshotter'
DOCKER_REPO_USER='intentmediateamcity'
export ANSIBLE_HOST_KEY_CHECKING=false

function remove_containers {
    echo "remove existing containers"
    stop_containers
    remove_existing_containers_and_images
}

function start_containers {
    : #no-op our application is run through cron
}

function stop_containers {
    echo "Stop Containers"
    docker stop $CONTAINER
}

function test_application {
    echo "Test Application"
    docker pull $CONTAINER
    #docker run --rm $CONTAINER ./run_tests.sh
}

function remove_existing_containers_and_images {
    echo "Remove dockers"
    docker rm -f $(docker ps -q -a) > /dev/null 2>&1 && echo 'All containers removed' || echo 'No containers to remove'
    docker rmi -f $(docker images -q) > /dev/null 2>&1 && echo 'All images removed' || echo 'No images to remove'
}

function build_containers {
    docker build -t $CONTAINER .
}

function tag_containers {
    push_containers "" "$BUILD_NUMBER"
}

function push_containers {
    from_suffix=$1
    tag_suffix=$2
    tag_name="$CONTAINER:$tag_suffix"

    echo "Log into docker repo: docker login --username=\"${DOCKER_REPO_USER}\""
    docker login --username="${DOCKER_REPO_USER}"

     if [ -z "$from_suffix" ]; then
        from_tag="$CONTAINER"
    else
        from_tag="${CONTAINER}:${from_suffix}"
    fi

    docker tag $from_tag $tag_name

    echo "Push Container: docker push $CONTAINER"
    docker push $CONTAINER
}

function promote_containers {
    echo "Promote container $BUILD_NUMBER to green"
    docker login --username="${DOCKER_REPO_USER}"
    docker pull $CONTAINER:$BUILD_NUMBER
    push_containers "${BUILD_NUMBER}" "green"
}

function deploy_containers {
    echo "Nothing to deploy"
}

function dev_containers {
    build_containers
    docker run -it -v $(PWD):/home/intentmedia/ --rm=true $CONTAINER /bin/bash
}

if [[ "$1" == "--start" ]]; then
    start_containers
elif [[ "$1" == "--test" ]]; then
    test_application
elif [[ "$1" == "--remove" ]]; then
    remove_containers
elif [[ "$1" == "--stop" ]]; then
    stop_containers
elif [[ "$1" == "--build" ]]; then
    build_containers
elif [[ "$1" == "--publish" ]]; then
    remove_existing_containers_and_images
    build_containers
    tag_containers
elif [[ "$1" == "--deploy" ]]; then
    deploy_containers
elif [[ "$1" == "--promote" ]]; then
    promote_containers
elif [[ "$1" == "--dev" ]]; then
    dev_containers
fi
