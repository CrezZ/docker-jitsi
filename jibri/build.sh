#!/bin/sh

#docker build -t jitsi2 . && \
docker build -t jibri2 .  && \
docker-compose -f my-jibri_docker-compose.yaml up -d



#docker-compose -f my-docker-compose.yaml up -d