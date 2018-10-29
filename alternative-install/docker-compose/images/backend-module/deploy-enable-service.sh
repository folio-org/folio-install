#!/bin/bash

#Allow a little time for okapi to come up. Not sure if needed but keeping in for now.
sleep 100;
#Check if module already registered. Important when you are not initializing DB
HTTPD=$(curl -X GET -H 'Content-type: application/json' -sL --connect-timeout 10 -w "%{http_code}\n" "$OKAPI_URL/_/discovery/modules/$MODULE-$TAG" -o /dev/null);
if [ "$HTTPD" -ge "400" ]; then
    #Register discovery modules
    DEPLOY_DESCRIPTOR={\"srvcId\":\""$MODULE"-"$TAG"\",\"instId\":\""$MODULE"-"$TAG"\",\"url\":\""$MODULE_URL"\"}
    HTTPD=$(curl -X POST -H 'Content-type: application/json' -sL -d "$DEPLOY_DESCRIPTOR" --connect-timeout 3 -w "%{http_code}\n" "$OKAPI_URL/_/discovery/modules" -o /dev/null);
    echo "$HTTPD";
    until [ "$HTTPD" -lt "400" ]; do
        printf '.'
        sleep 3
        HTTPD=$(curl -X POST -H 'Content-type: application/json' -sL -d "$DEPLOY_DESCRIPTOR" --connect-timeout 3 -w "%{http_code}\n" "$OKAPI_URL/_/discovery/modules" -o /dev/null);
    done;
fi

(eval "$START_CMD");
