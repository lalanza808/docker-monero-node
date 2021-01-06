#!/bin/bash

# Install packages
apt-get update
apt-get upgrade -y
apt-get install software-properties-common sudo git -y
# apt-get install certbot nginx python3 python3-virtualenv -y
# apt-get install docker.io docker-compose -y

# Setup certs
mkdir -p /etc/ssl/certs
openssl dhparam -out /etc/ssl/certs/dhparam.pem -2 2048
# service nginx stop
# certbot certonly --standalone -d ${DOMAIN} --agree-tos -m ${ACME_EMAIL} -n
# service nginx start

# Setup Nginx
mkdir -p /etc/nginx/conf.d
# rm -f /etc/nginx/sites-enabled/default
# cp conf/ssl.conf /etc/nginx/conf.d/ssl.conf
# cp conf/${DOMAIN}.conf /etc/nginx/sites-enabled/${DOMAIN}.conf
# nginx -t
# nginx -s reload

# Setup app users
useradd -m -s $(which false) monero

# Run Monero node as monero user
sudo -u monero bash -c "git clone https://github.com/lalanza808/docker-monero-node xnc && cd xnc && docker-compose up -d"
