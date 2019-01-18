#!/bin/sh

#mod-permissions
curl -w '\n' -D - -X POST  \
  -H "Content-type: application/json" \
   -d'{"id":"mod-permissions"}' \
   $OKAPI_URL/_/proxy/tenants/supertenant/modules

#Create superuser permissions
   cat > /usr/local/bin/folio/permuser.json <<END
{ "userId":"99999999-9999-9999-9999-999999999999",
  "permissions":[ "okapi.all" ] }
END

curl -w '\n' -D - -X POST  \
  -H "Content-type: application/json" \
  -H "X-Okapi-Tenant:supertenant" \
  -d@/usr/local/bin/folio/permuser.json \
   $OKAPI_URL/perms/users

#mod-users
curl -w '\n' -D - -X POST  \
  -H "Content-type: application/json" \
  -H "X-Okapi-Tenant:supertenant" \
  -d'{"id":"mod-users"}' \
  $OKAPI_URL/_/proxy/tenants/supertenant/modules

#Create superuser
  cat > /usr/local/bin/folio/superuser.json <<END
{ "id":"99999999-9999-9999-9999-999999999999",
  "username":"$SUPER_USR",
  "personal": {
     "lastName": "$SUPER_USR",
     "firstName": "$SUPER_USR"
  }
}
END

curl -w '\n' -D - -X POST  \
  -H "Content-type: application/json" \
  -H "X-Okapi-Tenant:supertenant" \
  -d@/usr/local/bin/folio/superuser.json \
   $OKAPI_URL/users

#mod-login
curl -w '\n' -D - -X POST  \
  -H "Content-type: application/json" \
  -H "X-Okapi-Tenant:supertenant" \
  -d'{"id":"mod-login"}' \
  $OKAPI_URL/_/proxy/tenants/supertenant/modules

#Create superuser password
  cat >/usr/local/bin/folio/loginuser.json << END
{ "username":"$SUPER_USR",
  "password":"$SUPER_PSSWD" }
END

curl -w '\n' -D - -X POST  \
  -H "Content-type: application/json" \
  -H "X-Okapi-Tenant:supertenant" \
  -d@/usr/local/bin/folio/loginuser.json \
   $OKAPI_URL/authn/credentials

#mod-authtoken
curl -w '\n' -D - -X POST  \
  -H "Content-type: application/json" \
  -H "X-Okapi-Tenant:supertenant" \
  -d'{"id":"mod-authtoken"}' \
  $OKAPI_URL/_/proxy/tenants/supertenant/modules
 