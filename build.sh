#!/bin/sh

docker build -t jitsi2 . && \
docker build -t jibri2 jibri/  && \
docker-compose -f my-jitsi_meet_jibri_docker-compose.yaml up -d



#docker-compose -f my-docker-compose.yaml up -d