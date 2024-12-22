#!/bin/bash

TOR_HOST=$(q tor A -r)
I2P_HOST=$(q i2p A -r)

set -x

monerod \
    --data-dir=/data \
    --p2p-bind-ip=0.0.0.0 \
    --p2p-bind-port=18080 \
    --rpc-restricted-bind-ip=0.0.0.0 \
    --rpc-restricted-bind-port=18081 \
    --zmq-rpc-bind-ip=0.0.0.0 \
    --zmq-rpc-bind-port=18082 \
    --rpc-bind-ip=0.0.0.0 \
    --rpc-bind-port=18083 \
    --non-interactive \
    --confirm-external-bind \
    --public-node \
    --log-level=0 \
    --enable-dns-blocklist \
    --rpc-ssl=disabled \
    --ban-list=/ban_list.txt \
    --tx-proxy=tor,$TOR_HOST:9050,disable_noise,24 \
    --tx-proxy=i2p,$I2P_HOST:4447,disable_noise,24

