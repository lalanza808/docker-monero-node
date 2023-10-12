#!/bin/bash

# Build and tag container images for all services; monerod, nodemapper, and exporter 
# All are manually tagged since some do not update as frequently as others. Bump the script
# to bump the image stored on Dockerhub.

set -ex

VERSION="${1}"
DH_USER=lalanza808
MONERO_VERSION=v0.18.3.1
MONERO_BASE=${DH_USER}/monerod
EXPORTER_VERSION=1.0.0
EXPORTER_BASE=${DH_USER}/exporter
NODEMAPPER_VERSION=1.0.0
NODEMAPPER_BASE=${DH_USER}/nodemapper


# build nodemapper
docker build -t "${NODEMAPPER_BASE}:${NODEMAPPER_VERSION}" -f dockerfiles/nodemapper .
docker tag "${NODEMAPPER_BASE}:${NODEMAPPER_VERSION}" "${NODEMAPPER_BASE}:latest"
docker push "${NODEMAPPER_BASE}:${NODEMAPPER_VERSION}"
docker push "${NODEMAPPER_BASE}:latest"

# build exporter
docker build -t "${EXPORTER_BASE}:${EXPORTER_VERSION}" -f dockerfiles/exporter .
docker tag "${EXPORTER_BASE}:${EXPORTER_VERSION}" "${EXPORTER_BASE}:latest"
docker push "${EXPORTER_BASE}:${EXPORTER_VERSION}"
docker push "${EXPORTER_BASE}:latest"

# build monerod

docker build -t "${MONERO_BASE}:${MONERO_VERSION}" -f dockerfiles/nodemapper .
docker tag "${MONERO_BASE}:${MONERO_VERSION}" "${MONERO_BASE}:latest"
docker push "${MONERO_BASE}:${MONERO_VERSION}"
docker push "${MONERO_BASE}:latest"
