#!/bin/sh

# Generate Deployment Descriptors

cd deploy-descriptors
#Authtoken
cat > deployment-descriptor-authtoken.json <<END
{
  "srvcId" : "mod-authtoken-1.4.1-SNAPSHOT.21",
  "instId" : "mod-authtoken-1.4.1-SNAPSHOT.21",
  "url" : "http://mod-authtoken:8081"
}
END

#calendar
cat > deployment-descriptor-calendar.json <<END
{
  "srvcId" : "mod-calendar-1.0.0-SNAPSHOT.37",
  "instId" : "mod-calendar-1.0.0-SNAPSHOT.37",
  "url" : "http://mod-calendar:8081"
}
END

#Permissions
cat > deployment-descriptor-permissions.json <<END
{
  "srvcId" : "mod-permissions-5.2.5-SNAPSHOT.22",
  "instId" : "mod-permissions-5.2.5-SNAPSHOT.22",
  "url" : "http://mod-permissions:8081"
}
END

#Login
cat > deployment-descriptor-login.json <<END
{
  "srvcId" : "mod-login-4.1.0-SNAPSHOT.12",
  "instId" : "mod-login-4.1.0-SNAPSHOT.12",
  "url" : "http://mod-login:8081"
}
END

#Configuration
cat > deployment-descriptor-configuration.json <<END
{
  "srvcId" : "mod-configuration-4.0.4-SNAPSHOT.36",
  "instId" : "mod-configuration-4.0.4-SNAPSHOT.36",
  "url" : "http://mod-configuration:8081"
}
END

#Users
cat > deployment-descriptor-users.json <<END
{
  "srvcId" : "mod-users-15.1.0-SNAPSHOT.36",
  "instId" : "mod-users-15.1.0-SNAPSHOT.36",
  "url" : "http://mod-users:8081"
}
END

#Users-bl
cat > deployment-descriptor-users-bl.json <<END
{
  "srvcId" : "mod-users-bl-3.0.0-SNAPSHOT.17",
  "instId" : "mod-users-bl-3.0.0-SNAPSHOT.17",
  "url" : "http://mod-users-bl:8081"
}
END

#user-import
cat > deployment-descriptor-user-import.json <<END
{
  "srvcId" : "mod-user-import-3.1.0-SNAPSHOT.28",
  "instId" : "mod-user-import-3.1.0-SNAPSHOT.28",
  "url" : "http://mod-user-import:8081"
}
END

#login-saml
cat > deployment-descriptor-login-saml.json <<END
{
  "srvcId" : "mod-login-saml-1.1.0-SNAPSHOT.23",
  "instId" : "mod-login-saml-1.1.0-SNAPSHOT.23",
  "url" : "http://mod-login-saml:8081"
}
END

#Inventory-storage
cat > deployment-descriptor-inventory-storage.json <<END
{
  "srvcId" : "mod-inventory-storage-12.1.0-SNAPSHOT.128",
  "instId" : "mod-inventory-storage-12.1.0-SNAPSHOT.128",
  "url" : "http://mod-inventory-storage:8081"
}
END

#Inventory
cat > deployment-descriptor-inventory.json <<END
{
  "srvcId" : "mod-inventory-9.1.0-SNAPSHOT.88",
  "instId" : "mod-inventory-9.1.0-SNAPSHOT.88",
  "url" : "http://mod-inventory:9403"
}
END

#codex-inventory
cat > deployment-descriptor-codex-inventory.json <<END
{
  "srvcId" : "mod-codex-inventory-1.2.0-SNAPSHOT.53",
  "instId" : "mod-codex-inventory-1.2.0-SNAPSHOT.53",
  "url" : "http://mod-codex-inventory:8081"
}
END

#Circulation-storage
cat > deployment-descriptor-circulation-storage.json <<END
{
  "srvcId" : "mod-circulation-storage-5.3.0-SNAPSHOT.93",
  "instId" : "mod-circulation-storage-5.3.0-SNAPSHOT.93",
  "url" : "http://mod-circulation-storage:8081"
}
END

#Circulation
cat > deployment-descriptor-circulation.json <<END
{
  "srvcId" : "mod-circulation-10.7.0-SNAPSHOT.160",
  "instId" : "mod-circulation-10.7.0-SNAPSHOT.160",
  "url" : "http://mod-circulation:9801"
}
END

#Notify
cat > deployment-descriptor-notify.json <<END
{
  "srvcId" : "mod-notify-1.1.7-SNAPSHOT.46",
  "instId" : "mod-notify-1.1.7-SNAPSHOT.46",
  "url" : "http://mod-notify:8081"
}
END

#Notes
cat > deployment-descriptor-notes.json <<END
{
  "srvcId" : "mod-notes-2.1.1-SNAPSHOT.57",
  "instId" : "mod-notes-2.1.1-SNAPSHOT.57",
  "url" : "http://mod-notes:8081"
}
END

#kb-ebsco
cat > deployment-descriptor-kb-ebsco.json <<END
{
  "srvcId" : "mod-kb-ebsco-0.1.1-SNAPSHOT.112",
  "instId" : "mod-kb-ebsco-0.1.1-SNAPSHOT.112",
  "url" : "http://mod-kb-ebsco:8081"
}
END

#codex-mux
cat > deployment-descriptor-codex-mux.json <<END
{
  "srvcId" : "mod-codex-mux-2.2.2-SNAPSHOT.55",
  "instId" : "mod-codex-mux-2.2.2-SNAPSHOT.55",
  "url" : "http://mod-codex-mux:8081"
}
END

#codex-ekb
cat > deployment-descriptor-codex-ekb.json <<END
{
  "srvcId" : "mod-codex-ekb-1.0.1-SNAPSHOT.64",
  "instId" : "mod-codex-ekb-1.0.1-SNAPSHOT.64",
  "url" : "http://mod-codex-ekb:8081"
}
END

#graphql
cat > deployment-descriptor-graphql.json <<END
{
  "srvcId" : "mod-graphql-0.1.1000112",
  "instId" : "mod-graphql-0.1.1000112",
  "url" : "http://mod-graphql:8081"
}
END

#vendors
cat > deployment-descriptor-vendors.json <<END
{
  "srvcId" : "mod-vendors-1.0.1-SNAPSHOT.20",
  "instId" : "mod-vendors-1.0.1-SNAPSHOT.20",
  "url" : "http://mod-vendors:8081"
}
END

#data-loader
cat > deployment-descriptor-data-loader.json <<END
{
  "srvcId" : "mod-data-loader-1.0.0",
  "instId" : "mod-data-loader-1.0.0",
  "url" : "http://mod-data-loader:8081"
}
END

# POST to proxy/modules, discovery/modules, and proxy/tenants/diku/modules

cd ..

#Authtoken
curl -i -w '\n' -X POST -H 'Content-type: application/json' \
-d @module-descriptors/module-authtoken.json http://okapi:9130/_/proxy/modules

curl -i -w '\n' -X POST -H 'Content-type: application/json' \
-d @deploy-descriptors/deployment-descriptor-authtoken.json http://okapi:9130/_/discovery/modules

curl -i -w '\n' -X POST -H 'Content-type: application/json' \
-d @tenant/enable-authtoken.json http://okapi:9130/_/proxy/tenants/diku/modules

#calendar
curl -i -w '\n' -X POST -H 'Content-type: application/json' \
-d @module-descriptors/module-calendar.json http://okapi:9130/_/proxy/modules

curl -i -w '\n' -X POST -H 'Content-type: application/json' \
-d @deploy-descriptors/deployment-descriptor-calendar.json http://okapi:9130/_/discovery/modules

curl -i -w '\n' -X POST -H 'Content-type: application/json' \
-d @tenant/enable-calendar.json http://okapi:9130/_/proxy/tenants/diku/modules

#Permissions
curl -i -w '\n' -X POST -H 'Content-type: application/json' \
-d @module-descriptors/module-permissions.json http://okapi:9130/_/proxy/modules

curl -i -w '\n' -X POST -H 'Content-type: application/json' \
-d @deploy-descriptors/deployment-descriptor-permissions.json http://okapi:9130/_/discovery/modules

curl -i -w '\n' -X POST -H 'Content-type: application/json' \
-d @tenant/enable-permissions.json http://okapi:9130/_/proxy/tenants/diku/modules

#Login
curl -i -w '\n' -X POST -H 'Content-type: application/json' \
-d @module-descriptors/module-login.json http://okapi:9130/_/proxy/modules

curl -i -w '\n' -X POST -H 'Content-type: application/json' \
-d @deploy-descriptors/deployment-descriptor-login.json http://okapi:9130/_/discovery/modules

curl -i -w '\n' -X POST -H 'Content-type: application/json' \
-d @tenant/enable-login.json http://okapi:9130/_/proxy/tenants/diku/modules

#Configuration
curl -i -w '\n' -X POST -H 'Content-type: application/json' \
-d @module-descriptors/module-configuration.json http://okapi:9130/_/proxy/modules

curl -i -w '\n' -X POST -H 'Content-type: application/json' \
-d @deploy-descriptors/deployment-descriptor-configuration.json http://okapi:9130/_/discovery/modules

curl -i -w '\n' -X POST -H 'Content-type: application/json' \
-d @tenant/enable-configuration.json http://okapi:9130/_/proxy/tenants/diku/modules

#Users
curl -i -w '\n' -X POST -H 'Content-type: application/json' \
-d @module-descriptors/module-users.json http://okapi:9130/_/proxy/modules

curl -i -w '\n' -X POST -H 'Content-type: application/json' \
-d @deploy-descriptors/deployment-descriptor-users.json http://okapi:9130/_/discovery/modules

curl -i -w '\n' -X POST -H 'Content-type: application/json' \
-d @tenant/enable-users.json http://okapi:9130/_/proxy/tenants/diku/modules

#Users-bl
curl -i -w '\n' -X POST -H 'Content-type: application/json' \
-d @module-descriptors/module-users-bl.json http://okapi:9130/_/proxy/modules

curl -i -w '\n' -X POST -H 'Content-type: application/json' \
-d @deploy-descriptors/deployment-descriptor-users-bl.json http://okapi:9130/_/discovery/modules

curl -i -w '\n' -X POST -H 'Content-type: application/json' \
-d @tenant/enable-users-bl.json http://okapi:9130/_/proxy/tenants/diku/modules

#user-import
curl -i -w '\n' -X POST -H 'Content-type: application/json' \
-d @module-descriptors/module-user-import.json http://okapi:9130/_/proxy/modules

curl -i -w '\n' -X POST -H 'Content-type: application/json' \
-d @deploy-descriptors/deployment-descriptor-user-import.json http://okapi:9130/_/discovery/modules

curl -i -w '\n' -X POST -H 'Content-type: application/json' \
-d @tenant/enable-user-import.json http://okapi:9130/_/proxy/tenants/diku/modules

#login-saml
curl -i -w '\n' -X POST -H 'Content-type: application/json' \
-d @module-descriptors/module-login-saml.json http://okapi:9130/_/proxy/modules

curl -i -w '\n' -X POST -H 'Content-type: application/json' \
-d @deploy-descriptors/deployment-descriptor-login-saml.json http://okapi:9130/_/discovery/modules

curl -i -w '\n' -X POST -H 'Content-type: application/json' \
-d @tenant/enable-login-saml.json http://okapi:9130/_/proxy/tenants/diku/modules

#Inventory-Storage
curl -i -w '\n' -X POST -H 'Content-type: application/json' \
-d @module-descriptors/module-inventory-storage.json http://okapi:9130/_/proxy/modules

curl -i -w '\n' -X POST -H 'Content-type: application/json' \
-d @deploy-descriptors/deployment-descriptor-inventory-storage.json http://okapi:9130/_/discovery/modules

curl -i -w '\n' -X POST -H 'Content-type: application/json' \
-d @tenant/enable-inventory-storage.json http://okapi:9130/_/proxy/tenants/diku/modules

#Inventory
curl -i -w '\n' -X POST -H 'Content-type: application/json' \
-d @module-descriptors/module-inventory.json http://okapi:9130/_/proxy/modules

curl -i -w '\n' -X POST -H 'Content-type: application/json' \
-d @deploy-descriptors/deployment-descriptor-inventory.json http://okapi:9130/_/discovery/modules

curl -i -w '\n' -X POST -H 'Content-type: application/json' \
-d @tenant/enable-inventory.json http://okapi:9130/_/proxy/tenants/diku/modules

#codex-inventory
curl -i -w '\n' -X POST -H 'Content-type: application/json' \
-d @module-descriptors/module-codex-inventory.json http://okapi:9130/_/proxy/modules

curl -i -w '\n' -X POST -H 'Content-type: application/json' \
-d @deploy-descriptors/deployment-descriptor-codex-inventory.json http://okapi:9130/_/discovery/modules

curl -i -w '\n' -X POST -H 'Content-type: application/json' \
-d @tenant/enable-codex-inventory.json http://okapi:9130/_/proxy/tenants/diku/modules

#Circulation-storage
curl -i -w '\n' -X POST -H 'Content-type: application/json' \
-d @module-descriptors/module-circulation-storage.json http://okapi:9130/_/proxy/modules

curl -i -w '\n' -X POST -H 'Content-type: application/json' \
-d @deploy-descriptors/deployment-descriptor-circulation-storage.json http://okapi:9130/_/discovery/modules

curl -i -w '\n' -X POST -H 'Content-type: application/json' \
-d @tenant/enable-circulation-storage.json http://okapi:9130/_/proxy/tenants/diku/modules

#Circulation
curl -i -w '\n' -X POST -H 'Content-type: application/json' \
-d @module-descriptors/module-circulation.json http://okapi:9130/_/proxy/modules

curl -i -w '\n' -X POST -H 'Content-type: application/json' \
-d @deploy-descriptors/deployment-descriptor-circulation.json http://okapi:9130/_/discovery/modules

curl -i -w '\n' -X POST -H 'Content-type: application/json' \
-d @tenant/enable-circulation.json http://okapi:9130/_/proxy/tenants/diku/modules

#Notify
curl -i -w '\n' -X POST -H 'Content-type: application/json' \
-d @module-descriptors/module-notify.json http://okapi:9130/_/proxy/modules

curl -i -w '\n' -X POST -H 'Content-type: application/json' \
-d @deploy-descriptors/deployment-descriptor-notify.json http://okapi:9130/_/discovery/modules

curl -i -w '\n' -X POST -H 'Content-type: application/json' \
-d @tenant/enable-notify.json http://okapi:9130/_/proxy/tenants/diku/modules

#Notes
curl -i -w '\n' -X POST -H 'Content-type: application/json' \
-d @module-descriptors/module-notes.json http://okapi:9130/_/proxy/modules

curl -i -w '\n' -X POST -H 'Content-type: application/json' \
-d @deploy-descriptors/deployment-descriptor-notes.json http://okapi:9130/_/discovery/modules

curl -i -w '\n' -X POST -H 'Content-type: application/json' \
-d @tenant/enable-notes.json http://okapi:9130/_/proxy/tenants/diku/modules

#KB-Ebsco
curl -i -w '\n' -X POST -H 'Content-type: application/json' \
-d @module-descriptors/module-kb-ebsco.json http://okapi:9130/_/proxy/modules

curl -i -w '\n' -X POST -H 'Content-type: application/json' \
-d @deploy-descriptors/deployment-descriptor-kb-ebsco.json http://okapi:9130/_/discovery/modules

curl -i -w '\n' -X POST -H 'Content-type: application/json' \
-d @tenant/enable-kb-ebsco.json http://okapi:9130/_/proxy/tenants/diku/modules

#Codex-mux
curl -i -w '\n' -X POST -H 'Content-type: application/json' \
-d @module-descriptors/module-codex-mux.json http://okapi:9130/_/proxy/modules

curl -i -w '\n' -X POST -H 'Content-type: application/json' \
-d @deploy-descriptors/deployment-descriptor-codex-mux.json http://okapi:9130/_/discovery/modules

curl -i -w '\n' -X POST -H 'Content-type: application/json' \
-d @tenant/enable-codex-mux.json http://okapi:9130/_/proxy/tenants/diku/modules

#Codex-ekb
curl -i -w '\n' -X POST -H 'Content-type: application/json' \
-d @module-descriptors/module-codex-ekb.json http://okapi:9130/_/proxy/modules

curl -i -w '\n' -X POST -H 'Content-type: application/json' \
-d @deploy-descriptors/deployment-descriptor-codex-ekb.json http://okapi:9130/_/discovery/modules

curl -i -w '\n' -X POST -H 'Content-type: application/json' \
-d @tenant/enable-codex-ekb.json http://okapi:9130/_/proxy/tenants/diku/modules

#graphql
curl -i -w '\n' -X POST -H 'Content-type: application/json' \
-d @module-descriptors/module-graphql.json http://okapi:9130/_/proxy/modules

curl -i -w '\n' -X POST -H 'Content-type: application/json' \
-d @deploy-descriptors/deployment-descriptor-graphql.json http://okapi:9130/_/discovery/modules

curl -i -w '\n' -X POST -H 'Content-type: application/json' \
-d @tenant/enable-graphql.json http://okapi:9130/_/proxy/tenants/diku/modules

#vendors
curl -i -w '\n' -X POST -H 'Content-type: application/json' \
-d @module-descriptors/module-vendors.json http://okapi:9130/_/proxy/modules

curl -i -w '\n' -X POST -H 'Content-type: application/json' \
-d @deploy-descriptors/deployment-descriptor-vendors.json http://okapi:9130/_/discovery/modules

curl -i -w '\n' -X POST -H 'Content-type: application/json' \
-d @tenant/enable-vendors.json http://okapi:9130/_/proxy/tenants/diku/modules

#data-loader
curl -i -w '\n' -X POST -H 'Content-type: application/json' \
-d @module-descriptors/module-data-loader.json http://okapi:9130/_/proxy/modules

curl -i -w '\n' -X POST -H 'Content-type: application/json' \
-d @deploy-descriptors/deployment-descriptor-data-loader.json http://okapi:9130/_/discovery/modules

curl -i -w '\n' -X POST -H 'Content-type: application/json' \
-d @tenant/enable-data-loader.json http://okapi:9130/_/proxy/tenants/diku/modules

# Register Stripes front-end

#!/bin/sh

#Calendar
curl -i -w '\n' -X POST -H 'Content-type: application/json' \
-d @stripes/module-descriptors/calendar.json http://okapi:9130/_/proxy/modules

curl -i -w '\n' -X POST -H 'Content-type: application/json' \
-d @stripes/tenant/calendar.json http://okapi:9130/_/proxy/tenants/diku/modules

#Checkin
curl -i -w '\n' -X POST -H 'Content-type: application/json' \
-d @stripes/module-descriptors/checkin.json http://okapi:9130/_/proxy/modules

curl -i -w '\n' -X POST -H 'Content-type: application/json' \
-d @stripes/tenant/checkin.json http://okapi:9130/_/proxy/tenants/diku/modules

#Checkout
curl -i -w '\n' -X POST -H 'Content-type: application/json' \
-d @stripes/module-descriptors/checkout.json http://okapi:9130/_/proxy/modules

curl -i -w '\n' -X POST -H 'Content-type: application/json' \
-d @stripes/tenant/checkout.json http://okapi:9130/_/proxy/tenants/diku/modules

#Circulation
curl -i -w '\n' -X POST -H 'Content-type: application/json' \
-d @stripes/module-descriptors/circulation.json http://okapi:9130/_/proxy/modules

curl -i -w '\n' -X POST -H 'Content-type: application/json' \
-d @stripes/tenant/circulation.json http://okapi:9130/_/proxy/tenants/diku/modules

#Developer
curl -i -w '\n' -X POST -H 'Content-type: application/json' \
-d @stripes/module-descriptors/developer.json http://okapi:9130/_/proxy/modules

curl -i -w '\n' -X POST -H 'Content-type: application/json' \
-d @stripes/tenant/developer.json http://okapi:9130/_/proxy/tenants/diku/modules

#eHoldings
curl -i -w '\n' -X POST -H 'Content-type: application/json' \
-d @stripes/module-descriptors/eholdings.json http://okapi:9130/_/proxy/modules

curl -i -w '\n' -X POST -H 'Content-type: application/json' \
-d @stripes/tenant/eholdings.json http://okapi:9130/_/proxy/tenants/diku/modules

#Inventory
curl -i -w '\n' -X POST -H 'Content-type: application/json' \
-d @stripes/module-descriptors/inventory.json http://okapi:9130/_/proxy/modules

curl -i -w '\n' -X POST -H 'Content-type: application/json' \
-d @stripes/tenant/inventory.json http://okapi:9130/_/proxy/tenants/diku/modules

#Organization
curl -i -w '\n' -X POST -H 'Content-type: application/json' \
-d @stripes/module-descriptors/organization.json http://okapi:9130/_/proxy/modules

curl -i -w '\n' -X POST -H 'Content-type: application/json' \
-d @stripes/tenant/organization.json http://okapi:9130/_/proxy/tenants/diku/modules

#plugin-find-user
curl -i -w '\n' -X POST -H 'Content-type: application/json' \
-d @stripes/module-descriptors/plugin-find-user.json http://okapi:9130/_/proxy/modules

curl -i -w '\n' -X POST -H 'Content-type: application/json' \
-d @stripes/tenant/plugin-find-user.json http://okapi:9130/_/proxy/tenants/diku/modules

#requests
curl -i -w '\n' -X POST -H 'Content-type: application/json' \
-d @stripes/module-descriptors/requests.json http://okapi:9130/_/proxy/modules

curl -i -w '\n' -X POST -H 'Content-type: application/json' \
-d @stripes/tenant/requests.json http://okapi:9130/_/proxy/tenants/diku/modules

#search
curl -i -w '\n' -X POST -H 'Content-type: application/json' \
-d @stripes/module-descriptors/search.json http://okapi:9130/_/proxy/modules

curl -i -w '\n' -X POST -H 'Content-type: application/json' \
-d @stripes/tenant/search.json http://okapi:9130/_/proxy/tenants/diku/modules

#users
curl -i -w '\n' -X POST -H 'Content-type: application/json' \
-d @stripes/module-descriptors/users.json http://okapi:9130/_/proxy/modules

curl -i -w '\n' -X POST -H 'Content-type: application/json' \
-d @stripes/tenant/users.json http://okapi:9130/_/proxy/tenants/diku/modules

#vendors
curl -i -w '\n' -X POST -H 'Content-type: application/json' \
-d @stripes/module-descriptors/vendors.json http://okapi:9130/_/proxy/modules

curl -i -w '\n' -X POST -H 'Content-type: application/json' \
-d @stripes/tenant/vendors.json http://okapi:9130/_/proxy/tenants/diku/modules

#stripes-smart-components
curl -i -w '\n' -X POST -H 'Content-type: application/json' \
-d @stripes/module-descriptors/stripes-smart-components.json http://okapi:9130/_/proxy/modules

curl -i -w '\n' -X POST -H 'Content-type: application/json' \
-d @stripes/tenant/stripes-smart-components.json http://okapi:9130/_/proxy/tenants/diku/modules

#stripes-core
curl -i -w '\n' -X POST -H 'Content-type: application/json' \
-d @stripes/module-descriptors/stripes-core.json http://okapi:9130/_/proxy/modules

curl -i -w '\n' -X POST -H 'Content-type: application/json' \
-d @stripes/tenant/stripes-core.json http://okapi:9130/_/proxy/tenants/diku/modules
