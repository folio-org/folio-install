#!/bin/bash

DEPLOY_DESCRIPTOR={\"srvcId\":\""$MODULE"-"$TAG"\",\"instId\":\""$MODULE"-"$TAG"\",\"url\":\""$MODULE_URL"\"}
HTTPD=$(curl -X POST -H 'Content-type: application/json' -sL -d "$DEPLOY_DESCRIPTOR" --connect-timeout 3 -w "%{http_code}\n" "$OKAPI_URL/_/discovery/modules" -o /dev/null);
echo "$HTTPD";
until [ "$HTTPD" -lt "400" ]; do
    printf '.'
    sleep 3
    HTTPD=$(curl -X POST -H 'Content-type: application/json' -sL -d "$DEPLOY_DESCRIPTOR" --connect-timeout 3 -w "%{http_code}\n" "$OKAPI_URL/_/discovery/modules" -o /dev/null);
done;

ENABLE_MODULE={\"id\":\""$MODULE"-"$TAG"\"}
HTTPD=$(curl -X POST -H 'Content-type: application/json' -sL -d "$ENABLE_MODULE" --connect-timeout 3 -w "%{http_code}\n" "$OKAPI_URL/_/proxy/tenants/$OKAPI_TENANT/modules" -o /dev/null);
until [ "$HTTPD" -lt "400" ]; do
    printf '.'
    sleep 3
    HTTPD=$(curl -X POST -H 'Content-type: application/json' -sL -d "$ENABLE_MODULE" --connect-timeout 3 -w "%{http_code}\n" "$OKAPI_URL/_/proxy/tenants/$OKAPI_TENANT/modules" -o /dev/null);
done;

./run-java.sh
