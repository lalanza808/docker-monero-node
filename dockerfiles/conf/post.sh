#!/bin/bash

ONION_ADDR=$(cat /var/lib/tor/monero/hostname)
ONION_URL="http://${ONION_ADDR}:18081"

curl -q -X POST https://monero.fail/add -d node_url=${ONION_URL}
