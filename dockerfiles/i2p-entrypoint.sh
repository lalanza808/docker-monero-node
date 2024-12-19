#!/bin/bash

chown -R i2p:i2p /home/i2p

# Run i2pd
sudo -u i2p i2pd \
    --httpproxy.enabled 1 \
    --httpproxy.address 0.0.0.0 \
    --httpproxy.port 4444
