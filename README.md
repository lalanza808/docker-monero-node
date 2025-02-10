# docker-monero-node

Simple way to run a Monero node with some monitoring and anonymity tools packaged in:

* [monero-exporter](https://github.com/cirocosta/monero-exporter) - exposes metrics of the daemon
* [nodemapper](./dockerfiles/nodemapper.py) - gathers GeoIP data for peers
* [Prometheus](https://prometheus.io/docs/introduction/overview/) - monitors the exporter
* [Grafana](https://grafana.com/) - shows visualizations and dashboards
* [tor](https://www.torproject.org/) - provides tx relays over tor proxy and a hidden service for wallets to connect to
* [i2pd](https://i2pd.website/) - provides tx relays over i2p proxy


## Setup

The only requirements are [Docker](https://docs.docker.com/get-docker/) and [Docker Compose](https://docs.docker.com/compose/install/). Ensure those are installed on your system. There's an optional `Makefile` provided if you'd like to use that, just ensure `make` is installed.

```
# Clone and enter the repository
git clone https://github.com/lalanza808/docker-monero-node
cd docker-monero-node

# OPTIONAL: Setup Grafana password, blockchain storage location, or port and container image tag overrides
cp env-example .env
vim .env

# Build containers
docker-compose build  # make build

# Run containers
docker-compose up -d  # make up

# See .onion hidden service address
docker logs tor
```

The following ports will be bound for `monerod` by default, but you can override in `.env`:
- 18080   # p2p
- 18081   # restricted rpc
- 18082   # zmq
- 18083   # unrestricted rpc

The following ports are commented out but can be enabled to test things locally:
- 9090  # prometheus web ui
- 3000  # grafana web ui
- 9000  # exporter web api (/metrics)
- 5000  # nodemapper web api (/metrics)
- 9050  # tor proxy
- 4444  # i2p http proxy
- 4447  # i2p socks proxy

There are two hard-coded IP addresses for the tor and i2p proxies (monerod requires an IP address for setting the `--tx-proxy` flag.) You will need to modify your compose file if you need to adjust them.

You will want to open/allow ports 18080 and 18081 in your firewall for usage as a remote/public node (or whichever p2p and restricted ports you picked).

Also, you may want to setup a reverse proxy to Grafana if you would like to expose the visualizations for the world to see. Be sure to lock down the administrative settings or leave login disabled! You can find a live example on my node here: https://singapore.node.xmr.pm

## Usage

It's fairly simple, use `docker-compose` to bring the containers up and down and look at logs.

```
# Run containers
docker-compose up -d            # make up

# Check all logs
docker-compose logs -f

# Check monerod logs
docker-compose logs -f monerod  # make logs
```

Navigate to http://localhost:3000 and log into Grafana. Find the `Node Stats` dashboard to get those sweet, sweet graphs.

If you've installed this on another system you will want to use [SSH tunnels](https://www.ssh.com/ssh/tunneling/example) (local forwarding) to reach Grafana (if not exposing via reverse proxy):

```
ssh <VPS OR SERVER IP> -L 3000:localhost:3000
```

Then navigate to http://localhost:3000. Here is what the graph looks like:

![](static/graf1.png)

![](static/graf2.png)

