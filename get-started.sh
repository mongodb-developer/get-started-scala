#!/bin/bash
MONGODB_URI=${1}
if [ -z ${MONGODB_URI} ]
then
    read -p "MONGODB URI (Required): " MONGODB_URI
fi 

DRIVER_VERSION=${2:-2.9.0}
echo "Executing ... "
docker run --rm -e MONGODB_URI=${MONGODB_URI} \
    -v "$(pwd)":/workspace \
    -w /workspace/scala ghcr.io/mongodb-developer/get-started-scala \
    "sed -i 's/\"mongo-scala-driver\" \% \"[x0-9]\+\.[x0-9]\+\.[x0-9]\+\"/\"mongo-scala-driver\" \% \"${DRIVER_VERSION}\"/g' \
    /workspace/scala/build.sbt; \
    sbt -Dsbt.ivy.home=/workspace/.ivy run"
