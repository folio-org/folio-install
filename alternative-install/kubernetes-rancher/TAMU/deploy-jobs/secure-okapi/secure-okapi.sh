#!/bin/sh

echo "Deploying modules to /_/discovery/modules"

# Generate module deployment descriptors

cd deploy-descriptors

cat > deployment-descriptor-users.json <<END
{
  "srvcId" : "mod-users-15.6.2",
  "instId" : "mod-users-15.6.2",
  "url" : "http://mod-users:8081"
}
END

cat > deployment-descriptor-permissions.json <<END
{
  "srvcId" : "mod-permissions-5.8.2",
  "instId" : "mod-permissions-5.8.2",
  "url" : "http://mod-permissions:8081"
}
END

cat > deployment-descriptor-login.json <<END
{
  "srvcId" : "mod-login-6.1.1",
  "instId" : "mod-login-6.1.1",
  "url" : "http://mod-login:8081"
}
END

cat > deployment-descriptor-authtoken.json <<END
{
  "srvcId" : "mod-authtoken-2.3.0",
  "instId" : "mod-authtoken-2.3.0",
  "url" : "http://mod-authtoken:8081"
}
END

sleep 2

# POST module deployment descriptors

cd ..

curl -i -w '\n' -X POST -H 'Content-type: application/json' \
-d @deploy-descriptors/deployment-descriptor-users.json $OKAPI_URL/_/discovery/modules

curl -i -w '\n' -X POST -H 'Content-type: application/json' \
-d @deploy-descriptors/deployment-descriptor-permissions.json $OKAPI_URL/_/discovery/modules

curl -i -w '\n' -X POST -H 'Content-type: application/json' \
-d @deploy-descriptors/deployment-descriptor-login.json $OKAPI_URL/_/discovery/modules

curl -i -w '\n' -X POST -H 'Content-type: application/json' \
-d @deploy-descriptors/deployment-descriptor-authtoken.json $OKAPI_URL/_/discovery/modules

sleep 2

# Secure Okapi

echo "Securing Okapi"

# Enable modules for supertenant

curl -w '\n' -D - -X POST -H "Content-type: application/json" \
-d @install/okapi-install.json \
$OKAPI_URL/_/proxy/tenants/$TENANT_ID/install?deploy=false\&preRelease=false\&tenantParameters=loadSample%3D$SAMPLE_DATA%2CloadReference%3D$REF_DATA


# Create superuser permissions

cat > /usr/local/bin/folio/permuser.json <<END
{
  "userId":"99999999-9999-9999-9999-999999999999",
  "permissions":[ "okapi.all" ]
}
END

curl -w '\n' -D - -X POST  \
-H "Content-type: application/json" \
-H "X-Okapi-Tenant:supertenant" \
-d @/usr/local/bin/folio/permuser.json \
$OKAPI_URL/perms/users

# Create superuser

cat > /usr/local/bin/folio/superuser.json <<END
{
  "id":"99999999-9999-9999-9999-999999999999",
  "username":"$SUPER_USR",
  "active":"true",
  "personal": {
     "lastName": "$SUPER_USR",
     "firstName": "$SUPER_USR"
   }
}
END

curl -w '\n' -D - -X POST  \
-H "Content-type: application/json" \
-H "X-Okapi-Tenant:supertenant" \
-d @/usr/local/bin/folio/superuser.json \
$OKAPI_URL/users

# Create superuser password

cat > /usr/local/bin/folio/loginuser.json << END
{ "username":"$SUPER_USR",
  "password":"$SUPER_PSSWD" }
END

curl -w '\n' -D - -X POST  \
-H "Content-type: application/json" \
-H "X-Okapi-Tenant:supertenant" \
-d @/usr/local/bin/folio/loginuser.json \
$OKAPI_URL/authn/credentials

# Enable mod-authtoken for supertenant

curl -w '\n' -D - -X POST  \
-H "Content-type: application/json" \
-H "X-Okapi-Tenant:supertenant" \
-d '{"id":"mod-authtoken-2.3.0"}' \
$OKAPI_URL/_/proxy/tenants/$TENANT_ID/modules

echo "Done!"
