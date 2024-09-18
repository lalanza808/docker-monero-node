#!/bin/bash

# Build and tag container images for each service based upon passed argument; monerod, nodemapper, or exporter
# All are manually tagged since some do not update as frequently as others. Bump the script
# to bump the image stored on Dockerhub.

set -ex

IMAGE=${1}
DH_USER=lalanza808
MONEROD_VERSION=v0.18.3.2
MONEROD_BASE=${DH_USER}/monerod
EXPORTER_VERSION=1.0.0
EXPORTER_BASE=${DH_USER}/exporter
NODEMAPPER_VERSION=1.0.2
NODEMAPPER_BASE=${DH_USER}/nodemapper

if [[ "${IMAGE}" == "nodemapper" ]]
then
    echo -e "[+] Building nodemapper"
    docker build -t "${NODEMAPPER_BASE}:${NODEMAPPER_VERSION}" -f dockerfiles/nodemapper .
    docker tag "${NODEMAPPER_BASE}:${NODEMAPPER_VERSION}" "${NODEMAPPER_BASE}:latest"
    docker push "${NODEMAPPER_BASE}:${NODEMAPPER_VERSION}"
    docker push "${NODEMAPPER_BASE}:latest"
fi

if [[ "${IMAGE}" == "exporter" ]]
then
    echo -e "[+] Building exporter"
    docker build -t "${EXPORTER_BASE}:${EXPORTER_VERSION}" -f dockerfiles/exporter .
    docker tag "${EXPORTER_BASE}:${EXPORTER_VERSION}" "${EXPORTER_BASE}:latest"
    docker push "${EXPORTER_BASE}:${EXPORTER_VERSION}"
    docker push "${EXPORTER_BASE}:latest"
fi

if [[ "${IMAGE}" == "monerod" ]]
then
    echo -e "[+] Building monerod"
    docker build -t "${MONEROD_BASE}:${MONEROD_VERSION}" -f dockerfiles/monero .
    docker tag "${MONEROD_BASE}:${MONEROD_VERSION}" "${MONEROD_BASE}:latest"
    docker push "${MONEROD_BASE}:${MONEROD_VERSION}"
    docker push "${MONEROD_BASE}:latest"
fi
