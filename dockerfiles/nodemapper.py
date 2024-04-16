#!/usr/bin/env python3

"""
This is a lightweight web service which will retrieve a peer list 
from a Monero node, determine GeoIP information, and return 
a list of metrics in a Prometheus compatible structure.
Use it to start plotting maps of active node connections.
"""

import socket, struct
from os import environ as env

import requests
import geoip2.database
from geoip2.errors import AddressNotFoundError
from flask import Flask, make_response


app = Flask(__name__)


NODE_HOST = env.get('NODE_HOST', 'monerod')
NODE_PORT = env.get('NODE_PORT', 18083)


def get_geoip(ip):
    """Takes an IP address and determines GeoIP data"""
    try:
        with geoip2.database.Reader("./geoip.mmdb") as reader:
            return reader.city(ip)
    except AddressNotFoundError:
        return None


@app.route("/metrics")
def nodes():
    """Return all nodes"""
    peers = list()
    peer_list = requests.get(f'http://{NODE_HOST}:{NODE_PORT}/get_peer_list').json()
    def add_peer(host, status):
        geo = get_geoip(host)
        if geo is None:
            return

        geostr = 'geoip{{latitude="{lat}", longitude="{lon}", country_code="{country_code}", country_name="{country_name}", status="{status}"}} 1'
        if geostr not in peers:
            if 'en' in geo.continent.names:
                peers.append(geostr.format(
                    lat=geo.location.latitude,
                    lon=geo.location.longitude,
                    country_code=geo.continent.code,
                    country_name=geo.continent.names['en'],
                    status=status
                ))
    for peer in peer_list['gray_list']:
        if peer.get('host'):
            add_peer(peer['host'], 'gray')
    for peer in peer_list['white_list']:
        if peer.get('host'):
            add_peer(peer['host'], 'white')
    data = '\n'.join(peers)
    response = make_response(data, 200)
    response.mimetype = "text/plain"
    return response
