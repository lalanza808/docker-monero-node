# docker-monero-node

Simple way to run a Monero daemon with some basic monitoring tools packaged in.

## Setup

The only requirements are [Docker](https://docs.docker.com/get-docker/) and [Docker Compose](https://docs.docker.com/compose/install/). Ensure those are installed on your system.

```
# Clone and enter the repository
git clone https://github.com/lalanza808/docker-monero-node
cd docker-monero-node

# Setup Grafana password and blockchain storage location
cp env-example .env
vim .env

# Start containers
docker-compose up -d
```

Navigate to http://localhost:3000 and log into Grafana. Find the `Daemon Stats` dashboard to get those sweet, sweet graphs.
