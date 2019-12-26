#!/bin/sh

docker build -t jitsi2 . && \
docker build -t jibri2 jibri/  && \
docker-compose -f my-docker-compose.yaml up -d