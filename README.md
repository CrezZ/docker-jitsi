# Jitsi Meet

forked from https://github.com/TeDomum/docker-jitsi for create new version with token auth and new UI

CHANGES:
- add new version of jitsi-web
- add token auth support
- add custom settings for tokens
- add STUN for jvb
- enable tokens and stun in config.js
- add settings for config.js in ENV
- add JIBRI support (https://github.com/CrezZ/docker-jibri) - Warning! RAM > 2Gb Required to correct working JIBRI+jitsi

Jitsi Meet is an audio/video conferencing software based on XMPP, Jitsi
Videobridge and lots of great sofware, available at
https://github.com/jitsi/jitsi-meet

This repository contains a simple Dockerfile with overloaded configuration
to run Jitsi Meet in a single Docker container. Only exception is the
STUN server, that you might want to run separately or use a public STUN
by any service provider.

## Build local

```
docker build -t my-jitsi .
```

## Running Jitsi Meet

You may simply run Jitsi Meet in Docker :

```
docker run -i -t -d -p 80:80 -p 4443:4443 -p 10000:10000/udp \
  -e DOMAIN=jitsi.mydomain.com -e STUN=stun.myprovider.com:19039 \
  -e BRIDGE_IP=1.2.3.4 crezz/docker-jitsi-2019
```
WARNING! WebRTC not work without SSL, you need using external SSL endpoint (nginx/haproxy + letsEncrypt).

## Example for SSL

0 jitse-meet package CANNOT run on custom port without chanhe the source code ! You need use differend DNS name (separate requests on nginx by server_name) or second IP for start jitsi-meet and you own site on 443 port. It hardcoded into jitsi-meet Javascript source

1 Start container for HTTP port 82 on localhost:

```
docker run -i -t -d -p 127.0.0.1:82:80 -p 4443:4443 -p 10000:10000/udp \
  -e DOMAIN=jitsi.mydomain.com -e STUN=stun.myprovider.com:19039 \
  -e BRIDGE_IP=1.2.3.4 crezz/docker-jitsi-2019
```
2 Configure nginx for webroot (or configure for youself preffered method)  (Change server_name!)

```
server {
        listen 80 default_server;
        listen [::]:80 default_server;
        server_name mcu.myserver.ru;

location /.well-known {
    root /var/www/html;
}

```
3 Install letsEncrypt and get certificate via webroot plugin (or you preffered way) (instruction for debian, use certbot manual for other systems)

```
apt-get install certbot python-certbot-nginx
certbot -d mcu.myserver.ru --webroot -w /var/www/html

```

4 Configure NGINX for SSL proxy to container

```

server {
        # SSL configuration
        #
         listen 443 ssl;
        server_name mcu.myserver.ru

    fastcgi_ignore_client_abort on;
    ssl_certificate /etc/letsencrypt/live/mcu.myserver.ru/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/mcu.myserver.ru/privkey.pem;

location /.well-known {
    root /var/www/html;
}


 add_header 'Access-Control-Allow-Origin' '*';
 add_header 'Access-Control-Allow-Credentials' 'true';
 add_header 'Access-Control-Allow-Headers' 'Authorization,Accept,Origin,DNT,X-CustomHeader,Keep-Alive,User-Agent,X-Requested
-With,If-Modified-Since,Cache-Control,Content-Type,Content-Range,Range';
 add_header 'Access-Control-Allow-Methods' 'GET,POST,OPTIONS,PUT,DELETE,PATCH';

 location / {
  if ($request_method = 'OPTIONS') {
      add_header 'Access-Control-Max-Age' 1728000;
      add_header 'Content-Type' 'text/plain charset=UTF-8';
      add_header 'Content-Length' 0;
      return 204;
    }

    proxy_redirect off;
    proxy_set_header Host $host;
    proxy_set_header X-real-ip $remote_addr;
    proxy_set_header X-forward-for $proxy_add_x_forwarded_for;
    proxy_pass http://127.0.0.1:82;
 }

}

  -e DOMAIN=jitsi.mydomain.com -e STUN=stun.myprovider.com \
  -e BRIDGE_IP=1.2.3.4 crezz/jitsi-meet-2019
```

Or use Docker Compose :

```
[...]
services:
  jitsi:
    image: crezz/
    image: crezz/jitsi-meet-2019
    image: crezz/jitsi-meet-2019
    ports:
      - 80:80
      - 4443:4443
      - 10000:10000/udp
    environment:
      - DOMAIN=mcu2.mydomain.com
      - BRIDGE_IP=11.22.33.44
      - STUN=stun4.l.google.com:19302
```

## Exposing the service

It is highly recommended to use nginx, traefik or any popular reverse proxy
in front of Jitsi Meet, and to configure a proper TLS endpoint.

Apart from port `80` which serves the HTTP application, ports `4443` and
`10000/udp` are actually bound by the Jitsi videobridge and required to be
forwarded directly.

You may set the proper bridge IP as well as public TCP and UDP port if
different from the default ones using `BRIDGE_IP`, `BRIDGE_TCP_PORT` and
`BRIDGE_UDP_PORT`.

## Configuration

The following configuration variables are expected in the environment.

| Variable   | Required(def)   | Purpose                    | Example            |
|------------|------------|----------------------------|--------------------|
| `DOMAIN` | yes | Public HTTP domain for the service | jitsi.mydomain.com |
| `STUN` | yes | DNS name to a STUn server | stun.myprovider.com |
| `BRIDGE_IP` | yes | Public IP exposing bridge ports | 1.2.3.4 |
| `BRIDGE_TCP_PORT` | no (4443) | Exposed bridge TCP port | 4443 |
| `BRIDGE_UDP_PORT` | no (10000) | Exposed bridge UDP port | 10000 |
| `JWT_APP_SECRET`  | no ('docker_jitsi_secret') | Use for token JWT auth | 'my_secret' |
| `JWT_APP_ID` | no ('docker_jitsi') | Use for token JWT auth | 'my_app' |
| `AUTH_TYPE` | no ('token') | 'token' auth or 'memory' internal auth | 'token' |
| `JS_ENABLE_TOKEN` | no (true) | For web GUI: 'true' - enable auth; 'false' - disable auth | true |
| `JS_LANG` | no ('ru') | 'en', 'ru' or others supporting languages for web GUI | 'ru' |


## JWT token EXAMPLE

You cannot add users or groups - JWT is method to send many user information (name, email, group, rights) via GET request. JWT ONLY method for HMAC (or RSA) sign this request with shared secret.

1 You need create JSON with some data (example via JS)

2 Next we need connect HMAC SHA256 library and calc the hash (for example we use jsrsasign.js)
```
<html>
<header>

<script language="JavaScript" type="text/javascript"
        src="https://kjur.github.io/jsrsasign/jsrsasign-latest-all-min.js">
</script>


</header>
JWT: <textarea cols=80 rows=10 id=t></textarea>

<script>

let header = {
  "kid": "jitsi/custom_key_name",
  "typ": "JWT",
  "alg": "HS256"        // Hash HMAC
};
let payload = {
  "context": {
    "user": {
      "avatar": "https:/gravatar.com/avatar/abc123",
      "name": "John Doe",
      "email": "jdoe@example.com",
      "id": "abcd:a1b2c3-d4e5f6-0abc1-23de-abcdef01fedcba" // only for internal usage
    },
    "group": "a123-123-456-789"         // only for internal usage
  },
  "aud": "jitsi",
  "iss": "JWT_APP_ID",                  // Required - as JWT_APP_ID env
  "sub": "DOMAIN",                      // Requied: as DOMAIN env
  "room": "*",                          // restricted room name or * for all room
  "exp": Date.now()+24*3600*1000,       // unix timestamp for expiration, for example 24 hours
  "moderator": true                     // true/false for room moderator role
};
let secret = 'JWT_APP_SECRET';


var JWT = KJUR.jws.JWS.sign("HS256", JSON.stringify(header), 
				JSON.stringify(payload), JSON.stringify(secret));
document.getElementById('t').value=JWT;
</script>
```

3 This code you need to use as 'jwt' GET parameter
```
http://mcu.youdomain.ru/roomid?jwt=eyJraWQiOiJqaXRzaS9jdXN0b21fa2V5X25hbWUiLCJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJjb250ZXh0Ijp7InVzZXIiOnsiYXZhdGFyIjoiaHR0cHM6L2dyYXZhdGFyLmNvbS9hdmF0YXIvYWJjMTIzIiwibmFtZSI6IkpvaG4gRG9lIiwiZW1haWwiOiJqZG9lQGV4YW1wbGUuY29tIiwiaWQiOiJhYmNkOmExYjJjMy1kNGU1ZjYtMGFiYzEtMjNkZS1hYmNkZWYwMWZlZGNiYSJ9LCJncm91cCI6ImExMjMtMTIzLTQ1Ni03ODkifSwiYXVkIjoiaml0c2kiLCJpc3MiOiJKV1RfQVBQX0lEIiwic3ViIjoiRE9NQUlOIiwicm9vbSI6IioiLCJleHAiOjE1NzY2NTQ1NTg4NzIsIm1vZGVyYXRvciI6dHJ1ZX0.vdxvmKznuIQsaP_PhV076LnpDFeQ-AK5GSMV2PXxqgc
```

#RECORD

For record using JIBRI. This is headless Chrome with selenium driver, which hidden view all participants and record any flows. It required at least 256 Mb RAM.


If you want to run JIBRI on a separate host, port 5222 from JITSI needs to be expose:
 ports:
    - 5222:5222
Don`t forget protect this port by iptables.

Standart docker start for JIBRI
```
docker run -e JIBRI_DOMAIN='mcu.youserver.ru' -e JIBRI_SECRET='321321321321' -e JIBRI_AUTH='123123123123' -e PROSODY_HOST=my.jitsi.host.or.docker.name  crezz/docker-jibri-2019
```

or via docker compose
1 Other host

```
version: '3'
services:
  jibri:
    image: crezz/docker-jibri-2019
    environment:
      - JIBRI_AUTH='123123123123'
      - JIBRI_SECRET='123123123123'
      - PROSODY_HOST=my.jitsi.host.or.docker.name
      - JIBRI_DOMAIN=mcu.myserver.ru
      - RECORD_PATH=/tmp/record
    volumes:
      - /tmp:/tmp/record

```


#RUN JIBRI and JITSI on single host

It required >2Gb RAM!

https://gitsub.com/crezz/docker-jibri

#CORS error prevent

If you browser get CORS error like this "" or this "" you need add to nginx this lines to location / and location /http-bind

```
location /http-bind {
 add_header 'Access-Control-Allow-Origin' '*';
 add_header 'Access-Control-Allow-Headers' 'Authorization,Accept,Origin,DNT,X-CustomHeader,Keep-Alive,User-Agent,X-Requested-With,If-Modified-Since,Cache-Control,Content-Type,Content-Range,Range';
...
}
```


## Limitations

Currently the following items are still limited:
- log management is almost non-existant
- process management could be improved
