#!/bin/bash

chown -R i2p:i2p /home/i2p

# Run i2pd
sudo -u i2p i2pd \
    --socksproxy.enabled 1 \
    --socksproxy.address 0.0.0.0 \
    --socksproxy.port 4447
