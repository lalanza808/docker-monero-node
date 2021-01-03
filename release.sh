#!/bin/bash

set -ex

TAG="${1}"
BASE=$(echo ${TAG} | cut -d":" -f1)

if [[ -z "${TAG}" ]]; then
  echo "You must specify a container tag. ex: lalanza808/monero:v0.17.1.8"
  exit 1
fi

docker build -t "${TAG}" -f dockerfiles/monero_nocompile .

docker tag "${TAG}" "${BASE}:latest"

docker push "${TAG}"

docker push "${BASE}:latest"
