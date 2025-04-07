#!/usr/bin/env python3

"""
This is a lightweight web service which will retrieve a peer list
from a Monero node, determine GeoIP information, and return
a list of metrics in a Prometheus compatible structure.
Use it to start plotting maps of active node connections.
"""

from os import environ as env
from typing import Union

import requests
import geoip2.database
from geoip2.models import City
from geoip2.errors import AddressNotFoundError
from flask import Flask, make_response


app = Flask(__name__)


NODE_HOST = env.get('NODE_HOST', 'monerod')
NODE_PORT = env.get('NODE_PORT', 18083)


def get_geoip(ip) -> Union[City, None]:
    """Takes an IP address and determines GeoIP data if possible"""
    try:
        with geoip2.database.Reader("./geoip.mmdb") as reader:
            return reader.city(ip)
    except AddressNotFoundError:
        print(f"{ip} not found in GeoIP database")
        return None
    except Exception as e:
        print(f"Error getting GeoIP data for {ip}: {e}")
        return None

def generate_prometheus_line(ip, status) -> Union[str, None]:
    """Generate a Prometheus formatted line for a given peer given an IP and status with GeoIP data included"""
    geo = get_geoip(ip)
    if geo is None or 'en' not in geo.continent.names:
        return None

    geostr = 'geoip{{latitude="{lat}", longitude="{lon}", country_code="{country_code}", country_name="{country_name}", status="{status}", ip="{ip}"}} 1'
    # print(f"Found GeoIP for {ip}: {geostr}")
    return geostr.format(
        lat=geo.location.latitude,
        lon=geo.location.longitude,
        country_code=geo.continent.code,
        country_name=geo.continent.names['en'],
        status=status,
        ip=ip
    )

@app.route("/metrics")
def nodes():
    """Get peer list from monerod and generate Prometheus endpoint output"""
    peers_found = list()
    prom_lines = list()
    peer_list = requests.get(f'http://{NODE_HOST}:{NODE_PORT}/get_peer_list').json()
    if not peer_list:
        return ""
    for peer in peer_list['gray_list']:
        peer['status'] = 'gray'
        peers_found.append(peer)
    for peer in peer_list['white_list']:
        peer['status'] = 'white'
        peers_found.append(peer)
    for peer in peers_found:
        prom = generate_prometheus_line(peer['host'], peer['status'])
        if prom:
            prom_lines.append(prom)
    response = make_response('\n'.join(prom_lines), 200)
    response.mimetype = "text/plain"
    return response
