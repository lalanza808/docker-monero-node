#!/bin/bash

set -e
set -x

export DEBIAN_FRONTEND=noninteractive

sleep 30

# Install packages
apt-get update
apt-get upgrade -y
apt-get install software-properties-common sudo git make -y
apt-get install certbot nginx python3 python3-virtualenv -y
apt-get install docker.io docker-compose -y
apt-get install tor -y

# Setup Tor
mkdir -p /run/tor
chown -R debian-tor:debian-tor /run/tor
chmod 700 -R /run/tor
mkdir -p /var/www/tor
cat << EOF > /etc/tor/torrc
BridgeRelay 1
ControlSocket /run/tor/control
ControlSocketsGroupWritable 1
CookieAuthentication 1
CookieAuthFileGroupReadable 1
CookieAuthFile /run/tor/control.authcookie
DataDirectory /var/lib/tor
ExitPolicy reject6 *:*, reject *:*
ExitRelay 0
IPv6Exit 0
Log notice stdout
ORPort 9001
PublishServerDescriptor 0
SOCKSPort 9051
HiddenServiceDir /var/lib/tor/monero
HiddenServicePort 18081
EOF
systemctl enable tor
systemctl restart tor
sleep 20
cp /var/lib/tor/monero/hostname /var/www/tor/index.html
chown -R nobody:nogroup /var/www/tor
chmod 644 /var/www/tor/index.html

# Setup certs and Nginx
mkdir -p /etc/nginx/conf.d
mkdir -p /etc/ssl/certs
rm -f /etc/nginx/sites-enabled/default
openssl dhparam -out /etc/ssl/certs/dhparam.pem -2 2048
cat << EOF > /etc/nginx/conf.d/ssl.conf
## SSL Certs are referenced in the actual Nginx config per-vhost
# Disable insecure SSL v2. Also disable SSLv3, as TLS 1.0 suffers a downgrade attack, allowing an attacker to force a connection to use SSLv3 and therefore disable forward secrecy.
# ssl_protocols TLSv1 TLSv1.1 TLSv1.2;
# Strong ciphers for PFS
ssl_ciphers 'EECDH+AESGCM:EDH+AESGCM:AES256+EECDH:AES256+EDH';
# Use server's preferred cipher, not the client's
# ssl_prefer_server_ciphers on;
ssl_session_cache shared:SSL:10m;
# Use ephemeral 4096 bit DH key for PFS
ssl_dhparam /etc/ssl/certs/dhparam.pem;
# Use OCSP stapling
ssl_stapling on;
ssl_stapling_verify on;
resolver 1.1.1.1 valid=300s;
resolver_timeout 5s;
EOF
cat << EOF > /etc/nginx/sites-enabled/${DOMAIN}.conf
# Redirect inbound http to https
server {
    listen 80 default_server;
    server_name ${DOMAIN};
    index index.php index.html;
    return 301 https://${DOMAIN}$request_uri;
}

# Load SSL configs and serve SSL site
server {
    listen 443 ssl;
    server_name ${DOMAIN};
    error_log /var/log/nginx/${DOMAIN}-error.log warn;
    access_log /var/log/nginx/${DOMAIN}-access.log;
    client_body_in_file_only clean;
    client_body_buffer_size 32K;
    # set max upload size
    client_max_body_size 8M;
    sendfile on;
    send_timeout 600s;

    location /grafana {
        proxy_pass http://127.0.0.1:3000;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Frame-Options "SAMEORIGIN";
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
        proxy_redirect off;
    }

    location /tor {
        alias /var/www/tor;
    }

    include conf.d/ssl.conf;
    ssl_certificate /etc/letsencrypt/live/${DOMAIN}/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/${DOMAIN}/privkey.pem;
}
EOF
service nginx stop
certbot certonly --standalone -d ${DOMAIN} --agree-tos -m ${ACME_EMAIL} -n
service nginx start

# Setup app users
useradd -m -s $(which false) monero
usermod -aG docker monero

# Setup Monero node
umount /dev/sda
mkdir -p /opt/monero
mount /dev/sda /opt/monero
rm -rf /opt/monero/*
git clone https://github.com/lalanza808/docker-monero-node /opt/monero
cat << EOF > /opt/monero/.env
DATA_DIR=/opt/monero/data
GRAFANA_URL=https://${DOMAIN}/grafana
GF_SERVER_SERVE_FROM_SUB_PATH=true
P2P_PORT=18080
RESTRICTED_PORT=18081
ZMQ_PORT=18082
UNRESTRICTED_PORT=18083
GF_AUTH_ANONYMOUS_ENABLED=true
GF_AUTH_BASIC_ENABLED=true
GF_AUTH_DISABLE_LOGIN_FORM=false
GF_SECURITY_ADMIN_PASSWORD=${GRAF_PASS}
GF_SECURITY_ADMIN_USER=${GRAF_USER}
EOF
chown -R monero:monero /opt/monero

# Run Monero node as monero user
sudo -u monero bash -c "cd /opt/monero && make up"

# Post nodes to monero.fail
ONION_ADDR=$(cat /var/lib/tor/monero/hostname)
ONION_URL="http://${ONION_ADDR}:18081"
CLEAR_URL="http://$(hostname).${DOMAIN}:18081"

curl -q -X POST https://monero.fail/add -d node_url="${ONION_URL}"
curl -q -X POST https://monero.fail/add -d node_url="${CLEAR_URL}"
