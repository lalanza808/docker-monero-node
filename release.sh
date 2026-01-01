#!/usr/bin/env bash

# Build and tag container images for each service based upon the passed argument.
# This version builds multi-arch images (linux/amd64 and linux/arm64) using Docker Buildx.
# Make sure you have set up buildx and QEMU emulation (if building on a different arch).
#
# Example usage:
#   ./release.sh monero
#   ./release.sh exporter
#

set -ex

IMAGE=${1}
DH_USER=${2:-lalanza808}
MONERO_VERSION=v0.18.4.4
MONERO_BASE=${DH_USER}/monero
EXPORTER_VERSION=1.0.0
EXPORTER_BASE=${DH_USER}/exporter
NODEMAPPER_VERSION=1.0.4
NODEMAPPER_BASE=${DH_USER}/nodemapper
TOR_VERSION=1.0.2
TOR_BASE=${DH_USER}/tor
I2P_VERSION=1.0.0
I2P_BASE=${DH_USER}/i2p

if [[ "${IMAGE}" == "nodemapper" ]]; then
    echo -e "[+] Building nodemapper multi-arch (amd64 & arm64)"
    docker buildx build --platform linux/amd64,linux/arm64 \
        -t "${NODEMAPPER_BASE}:${NODEMAPPER_VERSION}" \
        -t "${NODEMAPPER_BASE}:latest" \
        -f dockerfiles/nodemapper . \
        --push
fi

if [[ "${IMAGE}" == "exporter" ]]; then
    echo -e "[+] Building exporter multi-arch (amd64 & arm64)"
    docker buildx build --platform linux/amd64,linux/arm64 \
        -t "${EXPORTER_BASE}:${EXPORTER_VERSION}" \
        -t "${EXPORTER_BASE}:latest" \
        -f dockerfiles/exporter . \
        --push
fi

if [[ "${IMAGE}" == "monero" ]]; then
    echo -e "[+] Building monero multi-arch (amd64 & arm64)"
    docker buildx build --platform linux/amd64,linux/arm64 \
        -t "${MONERO_BASE}:${MONERO_VERSION}" \
        -t "${MONERO_BASE}:latest" \
        -f dockerfiles/monero . \
        --push
fi

if [[ "${IMAGE}" == "tor" ]]; then
    echo -e "[+] Building tor multi-arch (amd64 & arm64)"
    docker buildx build --platform linux/amd64,linux/arm64 \
        -t "${TOR_BASE}:${TOR_VERSION}" \
        -t "${TOR_BASE}:latest" \
        -f dockerfiles/tor . \
        --push
fi

if [[ "${IMAGE}" == "i2p" ]]; then
    echo -e "[+] Building i2p multi-arch (amd64 & arm64)"
    docker buildx build --platform linux/amd64,linux/arm64 \
        -t "${I2P_BASE}:${I2P_VERSION}" \
        -t "${I2P_BASE}:latest" \
        -f dockerfiles/i2p . \
        --push
fi

