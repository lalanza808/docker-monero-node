#!/bin/bash

docker build -t "lalanza808/monerod_exporter:1.0.0" -f monerod_exporter dockerfiles
docker tag lalanza808/monerod_exporter:1.0.0 lalanza808/monerod_exporter:latest
docker push lalanza808/monerod_exporter:1.0.0
docker push lalanza808/monerod_exporter:latest