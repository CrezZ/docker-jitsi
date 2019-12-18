#!/bin/sh

docker build -t jitsi2 . && \
docker-compose up -d 