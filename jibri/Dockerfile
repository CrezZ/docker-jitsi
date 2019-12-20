ARG JITSI_REPO=jitsi
#FROM ${JITSI_REPO}/base-java
FROM debian:stretch

ENV export LC_ALL=C
ENV export DEBIAN_FRONTEND=noninteractive

ARG CHROME_RELEASE=latest
ARG CHROMEDRIVER_MAJOR_RELEASE=latest

RUN apt-get -y update \
 && apt-get -y install --no-install-recommends gnupg2 ca-certificates wget procps \
      dnsutils nginx bash pwgen apt-transport-https ca-certificates git

RUN wget -qO - https://download.jitsi.org/jitsi-key.gpg.key | apt-key add - \
 && echo 'deb http://download.jitsi.org stable/' >> /etc/apt/sources.list \
 && apt-get -y update 

RUN  DEBIAN_FRONTEND=noninteractive apt-get install -y jibri 

RUN \
	[ "${CHROME_RELEASE}" = "latest" ] \
	&& curl -4s https://dl-ssl.google.com/linux/linux_signing_key.pub | apt-key add - \
	&& echo "deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main" > /etc/apt/sources.list.d/google-chrome.list \
	&&  apt-get update \
	&&  apt-get install -y google-chrome-stable \
	|| true

RUN \
        [ "${CHROME_RELEASE}" != "latest" ] \
        && curl -4so /tmp/google-chrome-stable_${CHROME_RELEASE}_amd64.deb http://dl.google.com/linux/chrome/deb/pool/main/g/google-chrome-stable/google-chrome-stable_${CHROME_RELEASE}_amd64.deb \
	&&  apt-get update \
        &&  apt-get install -y /tmp/google-chrome-stable_${CHROME_RELEASE}_amd64.deb \
	|| true

RUN \
	[ "${CHROMEDRIVER_MAJOR_RELEASE}" = "latest" ] \
	&& CHROMEDRIVER_RELEASE="$(curl -4Ls https://chromedriver.storage.googleapis.com/LATEST_RELEASE)" \
	|| CHROMEDRIVER_RELEASE="$(curl -4Ls https://chromedriver.storage.googleapis.com/LATEST_RELEASE_${CHROMEDRIVER_MAJOR_RELEASE})" \
	&& curl -4Ls https://chromedriver.storage.googleapis.com/${CHROMEDRIVER_RELEASE}/chromedriver_linux64.zip \
	| zcat >> /usr/bin/chromedriver \
	&& chmod +x /usr/bin/chromedriver \
	&& chromedriver --version

RUN \
        [ "$JITSI_RELEASE" = "unstable" ] \
        &&  apt-get update \
        &&  apt-get install -y jitsi-upload-integrations \
        || true

COPY config/jitsi /etc/jitsi

VOLUME /config

COPY start.sh /start.sh
COPY google-chrome /usr/bin/google-chrome

ENV PROSODY_HOST=localhost JIBRI_DOMAIN=docker RECORD_PATH=/tmp DISPLAY=:0

CMD /start.sh