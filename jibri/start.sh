#!/bin/bash

# Generate secrets if this is the first run
if [ ! -f /.fist-run ]; then

touch /.first-run
export JICOFO_SECRET=`pwgen -s 16 1`
export JVB_SECRET=`pwgen -s 16 1`
export FOCUS_SECRET=`pwgen -s 16 1`
if [[ -z "{{$JIBRI_AUTH}}"  ]]; then
    export JIBRI_AUTH=`pwgen -s 16 1`
fi
if [[ -z "{{$JIBRI_SECRET}}"  ]]; then
    export JIBRI_SECRET=`pwgen -s 16 1`
fi

# PATCH FOR MULTI INTERFACE in Docker ыwarm mode
#export LOCAL_IP=`grep $(hostname) /etc/hosts | cut -f1`
export LOCAL_IP=`ip route get 1 | head -1 | cut -d' ' -f7`

# Substitute configuration
for VARIABLE in `env | cut -f1 -d=`; do
  sed -i "s={{ $VARIABLE }}=${!VARIABLE}=g" /etc/jitsi/*/* 
done

#/etc/init.d/prosody restart
#hack prosody 11
#prosodyctl unregister focus 
#prosodyctl register focus "auth.$DOMAIN" $FOCUS_SECRET
#prosodyctl register jibri auth.$DOMAIN $JIBRI_AUTH
#prosodyctl register recorder recorder.$DOMAIN $JIBRI_SECRET

fi

# TODO: improve process management
#/etc/init.d/prosody restart
#/etc/init.d/jicofo restart
#/etc/init.d/jitsi-videobridge restart
#/etc/init.d/jibri restart


#exec nginx -g 'daemon off;'
#exec tail -f /var/log/jitsi/jibri/*
exec /opt/jitsi/jibri/launch.sh