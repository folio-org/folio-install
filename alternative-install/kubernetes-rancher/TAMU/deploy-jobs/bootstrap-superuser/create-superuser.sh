#!/bin/sh

#Create Super User
perl ./bootstrap-superuser.pl --tenant $TENANT_ID --user $ADMIN_USER --password $ADMIN_PASSWORD --okapi $OKAPI_URL