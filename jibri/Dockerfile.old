FROM debian:stretch

#CHANGE SECRET!!!

ARG DEBIAN_FRONTEND=noninteractive
ARG DOCKER_HOST=docker
ARG DOCKER_TOKEN_APP=docker_jitsi
ARG DOCKER_TOKEN_SECRET=docker_jitsi_secret
ARG STUN_DEFAULT=stun.l.google.com:19302,stun1.l.google.com:19302,stun2.l.google.com:19302

RUN apt-get -y update \
 && apt-get -y install --no-install-recommends gnupg2 ca-certificates wget procps \
      dnsutils nginx bash pwgen apt-transport-https ca-certificates git

RUN wget -qO - https://download.jitsi.org/jitsi-key.gpg.key | apt-key add - \
 && wget -qO - https://prosody.im/files/prosody-debian-packages.key  |  apt-key add - \
 && echo 'deb http://download.jitsi.org stable/' >> /etc/apt/sources.list \
 && echo 'deb https://packages.prosody.im/debian stretch main' >> /etc/apt/sources.list \
 && echo 'deb http://security.debian.org/debian-security jessie/updates main' >> /etc/apt/sources.list \
 && apt-get -y update \
 && apt-get -y   install prosody 

# IF NOT WORK - install manually prosody-trunk
#  && wget http://security.debian.org/debian-security/pool/updates/main/o/openssl/libssl1.0.0_1.0.1t-1+deb8u12_amd64.deb \
#  && dpkg -i libssl1.0.0_1.0.1t-1+deb8u12_amd64.deb  \
#  && wget https://packages.prosody.im/debian/pool/main/p/prosody/prosody_0.11.3-1~stretch2_amd64.deb \
#  && dpkg -i prosody_0.11.3-1~stretch2_amd64.deb \
# 


# HACK to prevent crash postinstall scripts
RUN  echo jicofo jitsi-videobridge/jvb-hostname string "${DOCKER_HOST}" | debconf-set-selections \
    && echo "jitsi-meet jitsi-meet/cert-choice select Self-signed certificate will be generated" | debconf-set-selections \
    && apt-get -y  install jitsi-meet 

# Hack to install tokens
RUN echo jitsi-meet-tokens  jitsi-meet-tokens/appid string "${DOCKER_TOKEN_APP}" | debconf-set-selections \
    && echo jitsi-meet-tokens jitsi-meet-tokens/appsecret string "${DOCKER_TOKEN_SECRET}" | debconf-set-selections \
    && apt-get -y install liblua5.1-0-dev liblua5.2-dev liblua50-dev  libssl1.0-dev luarocks\
    && luarocks install lua-cjson 2.1.0-1 \
    && luarocks install luacrypto \
    && luarocks install lbase64 \
    && apt-get -y install jitsi-meet-tokens 

# Install moderator token plugin
RUN git clone https://github.com/nvonahsen/jitsi-token-moderation-plugin \
    && cp -u jitsi-token-moderation-plugin/* /usr/share/jitsi-meet/prosody-plugins/ 
 


RUN rm -rf /etc/nginx/sites-enabled/* \
    && mv  /etc/prosody/conf.d/* /var/tmp \
    && cp /etc/prosody/prosody.cfg.lua /var/tmp
#    && rm -rf /etc/prosody/conf.d/*

COPY config/jitsi /etc/jitsi
RUN chown -R jicofo: /etc/jitsi/jicofo \
    && chown -R jvb: /etc/jitsi/videobridge

COPY config/nginx.conf /etc/nginx/nginx.conf
COPY config/prosody.cfg.lua /etc/prosody/prosody.cfg.lua

COPY start.sh /start.sh

ENV DOMAIN=test.com BRIDGE_IP=127.0.0.1 BRIDGE_TCP_PORT=4443 BRIDGE_UDP_PORT=10000 JVB_STUN_SERVERS=${STUN_DEFAULT} STUN=${STUN_DEFAULT} JWT_APP_SECRET=${DOCKER_TOKEN_SECRET} JWT_APP_ID=${DOKER_TOKEN_APP} AUTH_TYPE=token
ENV JS_ENABLE_TOKEN=false JS_LANG=ru


EXPOSE 4443 10000/udp

CMD /start.sh
