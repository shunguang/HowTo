#!/bin/bash

set -e

IMAGE="localhost/l4t-jetpack:r36.4.0-ffmpeg"
CONTAINER="ffmpeg-nvmpi"
DOCKERFILE="Dockerfile.ffmpeg"

IMAGE2="localhost/l4t-jetpack:r36.4.0-ffmpeg-built"
CONTAINER2="ffmpeg-test"
usage()
{
    echo "Usage: $0 {build|run_ffmpeg|run_ffmpeg_built|stop}"
    echo "       build:            build localhost/l4t-jetpack:r36.4.0-ffmpeg image"
    echo
    echo "       run_ffmpeg:       run ${CONTAINER} container from image ${IMAGE}"
    echo "                         this is used to build ffmpeg-nvmpi, x264, x265, ffmpeg"
    echo "                         when built done, you need to save a new iamge by run:"
    echo "                         podman commit ffmpeg-nvmpi localhost/l4t-jetpack:r36.4.0-ffmpeg-built"
    echo 
    echo "       run_ffmpeg_test:  run ${CONTAINER2} container from image ${IMAGE2}"
    echo
    echo "       stop:             stop both containers"	         
    exit 1
}

build_image()
{
    echo "=== Building image: ${IMAGE} ==="

    # Stop and remove existing container because it depends on the old image.
    if podman container exists "${CONTAINER}"; then
        echo "Removing existing container: ${CONTAINER}"
        podman rm -f "${CONTAINER}"
    fi

    # Remove existing image.
    if podman image exists "${IMAGE}"; then
        echo "Removing existing image: ${IMAGE}"
        podman rmi -f "${IMAGE}"
    fi

    echo "Building ${IMAGE} from ${DOCKERFILE}..."

    podman build \
        -f "${DOCKERFILE}" \
        -t "${IMAGE}" \
        .

    echo
    echo "=== Build complete ==="
    podman images "${IMAGE}"
}

run_container()
{
    local CURR_IMAGE="$1"
    local CURR_CONTAINER="$2"

    # Make sure the image exists.
    if ! podman image exists "${CURR_IMAGE}"; then
        echo "ERROR: Image does not exist:"
        echo "  ${CURR_IMAGE}"
        exit 1
    fi

    #
    # Container already exists.
    #
    if podman container exists "${CURR_CONTAINER}"; then

        RUNNING=$(podman inspect \
            -f '{{.State.Running}}' \
            "${CURR_CONTAINER}")

        if [ "${RUNNING}" = "true" ]; then
            echo "Container ${CURR_CONTAINER} is already running."
            echo "Attaching..."
            podman exec -it "${CURR_CONTAINER}" /bin/bash
        else
            echo "Starting existing container: ${CURR_CONTAINER}"
            podman start -ai "${CURR_CONTAINER}"
        fi

        return
    fi

    #
    # Container does not exist. Create it.
    #
    echo "Creating container: ${CURR_CONTAINER}"

    podman run -it \
        --name "${CURR_CONTAINER}" \
        -e DISPLAY \
        --net=host \
        --device nvidia.com/gpu=all \
        --group-add keep-groups \
        --security-opt label=disable \
        -v "${HOME}/test:/test" \
        -v /tmp/.X11-unix:/tmp/.X11-unix \
        -w /test \
        "${CURR_IMAGE}"
}

stop_container()
{
    local CURR_CONTAINER="$1"

    if [ -z "${CURR_CONTAINER}" ]; then
        echo "Usage: stop_container <container_name>"
        return 1
    fi

    if ! podman container exists "${CURR_CONTAINER}"; then
        echo "Container ${CURR_CONTAINER} does not exist."
        return 1
    fi

    local RUNNING
    RUNNING=$(podman inspect \
        -f '{{.State.Running}}' \
        "${CURR_CONTAINER}")

    if [ "${RUNNING}" = "true" ]; then
        echo "Stopping container: ${CURR_CONTAINER}"
        podman stop "${CURR_CONTAINER}"
    else
        echo "Container ${CURR_CONTAINER} is already stopped."
    fi
}

case "$1" in

    build)
        build_image
        ;;

    run_ffmpeg)
        run_container "${IMAGE}" "${CONTAINER}"
        ;;

    run_ffmpeg_test)
        run_container "${IMAGE2}" "${CONTAINER2}"
        ;;
	
    stop)
        stop_container "${CONTAINER}" 
        stop_container "${CONTAINER2}" 
        ;;

    *)
        usage
        ;;

esac
