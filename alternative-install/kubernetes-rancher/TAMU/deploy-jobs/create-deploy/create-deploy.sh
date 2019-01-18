#!/bin/sh

# Generate Deployment Descriptors

cd deploy-descriptors

#feesfines
cat > deployment-descriptor-feesfines.json <<END
{
  "srvcId" : "mod-feesfines-15.1.0",
  "instId" : "mod-feesfines-15.1.0",
  "url" : "http://mod-feesfines:8081"
}
END

#users
cat > deployment-descriptor-users.json <<END
{
  "srvcId" : "mod-users-15.3.0",
  "instId" : "mod-users-15.3.0",
  "url" : "http://mod-users:8081"
}
END

#password-validator
cat > deployment-descriptor-password-validator.json <<END
{
  "srvcId" : "mod-password-validator-1.0.1",
  "instId" : "mod-password-validator-1.0.1",
  "url" : "http://mod-password-validator:8081"
}
END

#permissions
cat > deployment-descriptor-permissions.json <<END
{
  "srvcId" : "mod-permissions-5.4.0",
  "instId" : "mod-permissions-5.4.0",
  "url" : "http://mod-permissions:8081"
}
END

#login
cat > deployment-descriptor-login.json <<END
{
  "srvcId" : "mod-login-4.6.0",
  "instId" : "mod-login-4.6.0",
  "url" : "http://mod-login:8081"
}
END

#inventory-storage
cat > deployment-descriptor-inventory-storage.json <<END
{
  "srvcId" : "mod-inventory-storage-14.0.0",
  "instId" : "mod-inventory-storage-14.0.0",
  "url" : "http://mod-inventory-storage:8081"
}
END

#configuration
cat > deployment-descriptor-configuration.json <<END
{
  "srvcId" : "mod-configuration-5.0.1",
  "instId" : "mod-configuration-5.0.1",
  "url" : "http://mod-configuration:8081"
}
END

#authtoken
cat > deployment-descriptor-authtoken.json <<END
{
  "srvcId" : "mod-authtoken-2.0.4",
  "instId" : "mod-authtoken-2.0.4",
  "url" : "http://mod-authtoken:8081"
}
END

#circulation-storage
cat > deployment-descriptor-circulation-storage.json <<END
{
  "srvcId" : "mod-circulation-storage-6.2.0",
  "instId" : "mod-circulation-storage-6.2.0",
  "url" : "http://mod-circulation-storage:8081"
}
END

#circulation
cat > deployment-descriptor-circulation.json <<END
{
  "srvcId" : "mod-circulation-14.1.0",
  "instId" : "mod-circulation-14.1.0",
  "url" : "http://mod-circulation:9801"
}
END

#inventory
cat > deployment-descriptor-inventory.json <<END
{
  "srvcId" : "mod-inventory-11.0.0",
  "instId" : "mod-inventory-11.0.0",
  "url" : "http://mod-inventory:9403"
}
END

#codex-mux
cat > deployment-descriptor-codex-mux.json <<END
{
  "srvcId" : "mod-codex-mux-2.3.0",
  "instId" : "mod-codex-mux-2.3.0",
  "url" : "http://mod-codex-mux:8081"
}
END

#codex-inventory
cat > deployment-descriptor-codex-inventory.json <<END
{
  "srvcId" : "mod-codex-inventory-1.4.0",
  "instId" : "mod-codex-inventory-1.4.0",
  "url" : "http://mod-codex-inventory:8081"
}
END

#login-saml
cat > deployment-descriptor-login-saml.json <<END
{
  "srvcId" : "mod-login-saml-1.2.1",
  "instId" : "mod-login-saml-1.2.1",
  "url" : "http://mod-login-saml:8081"
}
END

#notify
cat > deployment-descriptor-notify.json <<END
{
  "srvcId" : "mod-notify-2.1.0",
  "instId" : "mod-notify-2.1.0",
  "url" : "http://mod-notify:8081"
}
END

#notes
cat > deployment-descriptor-notes.json <<END
{
  "srvcId" : "mod-notes-2.2.0",
  "instId" : "mod-notes-2.2.0",
  "url" : "http://mod-notes:8081"
}
END

#users-bl
cat > deployment-descriptor-users-bl.json <<END
{
  "srvcId" : "mod-users-bl-4.3.2",
  "instId" : "mod-users-bl-4.3.2",
  "url" : "http://mod-users-bl:8081"
}
END

#tags
cat > deployment-descriptor-tags.json <<END
{
  "srvcId" : "mod-tags-0.2.0",
  "instId" : "mod-tags-0.2.0",
  "url" : "http://mod-tags:8081"
}
END

#codex-ekb
cat > deployment-descriptor-codex-ekb.json <<END
{
  "srvcId" : "mod-codex-ekb-1.1.0",
  "instId" : "mod-codex-ekb-1.1.0",
  "url" : "http://mod-codex-ekb:8081"
}
END

#kb-ebsco
cat > deployment-descriptor-kb-ebsco.json <<END
{
  "srvcId" : "mod-kb-ebsco-1.1.0",
  "instId" : "mod-kb-ebsco-1.1.0",
  "url" : "http://mod-kb-ebsco:8081"
}
END

#calendar
cat > deployment-descriptor-calendar.json <<END
{
  "srvcId" : "mod-calendar-1.2.0",
  "instId" : "mod-calendar-1.2.0",
  "url" : "http://mod-calendar:8081"
}
END

#vendors
cat > deployment-descriptor-vendors.json <<END
{
  "srvcId" : "mod-vendors-1.0.3",
  "instId" : "mod-vendors-1.0.3",
  "url" : "http://mod-vendors:8081"
}
END

#agreements
#cat > deployment-descriptor-agreements.json <<END
#{
#  "srvcId" : "mod-agreements-1.0.2",
#  "instId" : "mod-agreements-1.0.2",
#  "url" : "http://mod-agreements:8080"
#}
#END

#marccat
cat > deployment-descriptor-marccat.json <<END
{
  "srvcId" : "mod-marccat-1.2.0",
  "instId" : "mod-marccat-1.2.0",
  "url" : "http://mod-marccat:9403"
}
END

#template-engine
cat > deployment-descriptor-template-engine.json <<END
{
  "srvcId" : "mod-template-engine-1.0.1",
  "instId" : "mod-template-engine-1.0.1",
  "url" : "http://mod-template-engine:8081"
}
END

#finance-storage
cat > deployment-descriptor-finance-storage.json <<END
{
  "srvcId" : "mod-finance-storage-1.0.1",
  "instId" : "mod-finance-storage-1.0.1",
  "url" : "http://mod-finance-storage:8081"
}
END

#orders-storage
cat > deployment-descriptor-orders-storage.json <<END
{
  "srvcId" : "mod-orders-storage-1.0.2",
  "instId" : "mod-orders-storage-1.0.2",
  "url" : "http://mod-orders-storage:8081"
}
END

#source-record-storage
cat > deployment-descriptor-source-record-storage.json <<END
{
  "srvcId" : "mod-source-record-storage-1.0.0",
  "instId" : "mod-source-record-storage-1.0.0",
  "url" : "http://mod-source-record-storage:8081"
}
END

#source-record-manager
cat > deployment-descriptor-source-record-manager.json <<END
{
  "srvcId" : "mod-source-record-manager-0.1.0",
  "instId" : "mod-source-record-manager-0.1.0",
  "url" : "http://mod-source-record-manager:8081"
}
END

#event-config
cat > deployment-descriptor-event-config.json <<END
{
  "srvcId" : "mod-event-config-1.0.0",
  "instId" : "mod-event-config-1.0.0",
  "url" : "http://mod-event-config:8081"
}
END

#orders
cat > deployment-descriptor-orders.json <<END
{
  "srvcId" : "mod-orders-1.0.2",
  "instId" : "mod-orders-1.0.2",
  "url" : "http://mod-orders:8081"
}
END

#erm-usage
cat > deployment-descriptor-erm-usage.json <<END
{
  "srvcId" : "mod-erm-usage-1.0.0",
  "instId" : "mod-erm-usage-1.0.0",
  "url" : "http://mod-erm-usage:8081"
}
END

#erm-usage-harvester
cat > deployment-descriptor-erm-usage-harvester.json <<END
{
  "srvcId" : "mod-erm-usage-harvester-1.0.0",
  "instId" : "mod-erm-usage-harvester-1.0.0",
  "url" : "http://mod-erm-usage-harvester:8081"
}
END

#gobi
cat > deployment-descriptor-gobi.json <<END
{
  "srvcId" : "mod-gobi-1.0.1",
  "instId" : "mod-gobi-1.0.1",
  "url" : "http://mod-gobi:8081"
}
END

#data-import
cat > deployment-descriptor-data-import.json <<END
{
  "srvcId" : "mod-data-import-1.0.0",
  "instId" : "mod-data-import-1.0.0",
  "url" : "http://mod-data-import:8081"
}
END

#patron
cat > deployment-descriptor-patron.json <<END
{
  "srvcId" : "mod-patron-1.2.0",
  "instId" : "mod-patron-1.2.0",
  "url" : "http://mod-patron:8081"
}
END

#rtac
cat > deployment-descriptor-rtac.json <<END
{
  "srvcId" : "mod-rtac-1.2.1",
  "instId" : "mod-rtac-1.2.1",
  "url" : "http://mod-rtac:8081"
}
END

#email
cat > deployment-descriptor-email.json <<END
{
  "srvcId" : "mod-email-1.0.0",
  "instId" : "mod-email-1.0.0",
  "url" : "http://mod-email:8081"
}
END

#sender
cat > deployment-descriptor-sender.json <<END
{
  "srvcId" : "mod-sender-1.0.0",
  "instId" : "mod-sender-1.0.0",
  "url" : "http://mod-sender:8081"
}
END

#audit
cat > deployment-descriptor-audit.json <<END
{
  "srvcId" : "mod-audit-0.0.3",
  "instId" : "mod-audit-0.0.3",
  "url" : "http://mod-audit:8081"
}
END

#audit-filter
cat > deployment-descriptor-audit-filter.json <<END
{
  "srvcId" : "mod-audit-filter-0.0.3",
  "instId" : "mod-audit-filter-0.0.3",
  "url" : "http://mod-audit-filter:8081"
}
END

#licenses
#cat > deployment-descriptor-licenses.json <<END
#{
#  "srvcId" : "mod-licenses-1.0.2",
#  "instId" : "mod-licenses-1.0.2",
#  "url" : "http://mod-licenses:8080"
#}
#END

#oai-pmh
cat > deployment-descriptor-oai-pmh.json <<END
{
  "srvcId" : "mod-oai-pmh-1.0.1",
  "instId" : "mod-oai-pmh-1.0.1",
  "url" : "http://mod-oai-pmh:8080"
}
END

#user-import
cat > deployment-descriptor-user-import.json <<END
{
  "srvcId" : "mod-user-import-3.1.0",
  "instId" : "mod-user-import-3.1.0",
  "url" : "http://mod-user-import:8081"
}
END

#graphql
cat > deployment-descriptor-graphql.json <<END
{
  "srvcId" : "mod-graphql-1.1.0",
  "instId" : "mod-graphql-1.1.0",
  "url" : "http://mod-graphql:3000"
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

# POST to proxy/modules, discovery/modules, and proxy/tenants/mytenant/modules

cd ..

#feesfines
curl -i -w '\n' -X POST -H 'Content-type: application/json' \
-d @module-descriptors/module-feesfines.json $OKAPI_URL/_/proxy/modules

curl -i -w '\n' -X POST -H 'Content-type: application/json' \
-d @deploy-descriptors/deployment-descriptor-feesfines.json $OKAPI_URL/_/discovery/modules

curl -i -w '\n' -X POST -H 'Content-type: application/json' \
-d @tenant/enable-feesfines.json $OKAPI_URL/_/proxy/tenants/$TENANT_ID/modules

#users
curl -i -w '\n' -X POST -H 'Content-type: application/json' \
-d @module-descriptors/module-users.json $OKAPI_URL/_/proxy/modules

curl -i -w '\n' -X POST -H 'Content-type: application/json' \
-d @deploy-descriptors/deployment-descriptor-users.json $OKAPI_URL/_/discovery/modules

curl -i -w '\n' -X POST -H 'Content-type: application/json' \
-d @tenant/enable-users.json $OKAPI_URL/_/proxy/tenants/$TENANT_ID/modules

#password-validator
curl -i -w '\n' -X POST -H 'Content-type: application/json' \
-d @module-descriptors/module-password-validator.json $OKAPI_URL/_/proxy/modules

curl -i -w '\n' -X POST -H 'Content-type: application/json' \
-d @deploy-descriptors/deployment-descriptor-password-validator.json $OKAPI_URL/_/discovery/modules

curl -i -w '\n' -X POST -H 'Content-type: application/json' \
-d @tenant/enable-password-validator.json $OKAPI_URL/_/proxy/tenants/$TENANT_ID/modules

#permissions
curl -i -w '\n' -X POST -H 'Content-type: application/json' \
-d @module-descriptors/module-permissions.json $OKAPI_URL/_/proxy/modules

curl -i -w '\n' -X POST -H 'Content-type: application/json' \
-d @deploy-descriptors/deployment-descriptor-permissions.json $OKAPI_URL/_/discovery/modules

curl -i -w '\n' -X POST -H 'Content-type: application/json' \
-d @tenant/enable-permissions.json $OKAPI_URL/_/proxy/tenants/$TENANT_ID/modules

#login
curl -i -w '\n' -X POST -H 'Content-type: application/json' \
-d @module-descriptors/module-login.json $OKAPI_URL/_/proxy/modules

curl -i -w '\n' -X POST -H 'Content-type: application/json' \
-d @deploy-descriptors/deployment-descriptor-login.json $OKAPI_URL/_/discovery/modules

curl -i -w '\n' -X POST -H 'Content-type: application/json' \
-d @tenant/enable-login.json $OKAPI_URL/_/proxy/tenants/$TENANT_ID/modules

#inventory-storage
curl -i -w '\n' -X POST -H 'Content-type: application/json' \
-d @module-descriptors/module-inventory-storage.json $OKAPI_URL/_/proxy/modules

curl -i -w '\n' -X POST -H 'Content-type: application/json' \
-d @deploy-descriptors/deployment-descriptor-inventory-storage.json $OKAPI_URL/_/discovery/modules

curl -i -w '\n' -X POST -H 'Content-type: application/json' \
-d @tenant/enable-inventory-storage.json $OKAPI_URL/_/proxy/tenants/$TENANT_ID/modules

#configuration
curl -i -w '\n' -X POST -H 'Content-type: application/json' \
-d @module-descriptors/module-configuration.json $OKAPI_URL/_/proxy/modules

curl -i -w '\n' -X POST -H 'Content-type: application/json' \
-d @deploy-descriptors/deployment-descriptor-configuration.json $OKAPI_URL/_/discovery/modules

curl -i -w '\n' -X POST -H 'Content-type: application/json' \
-d @tenant/enable-configuration.json $OKAPI_URL/_/proxy/tenants/$TENANT_ID/modules

#authtoken
curl -i -w '\n' -X POST -H 'Content-type: application/json' \
-d @module-descriptors/module-authtoken.json $OKAPI_URL/_/proxy/modules

curl -i -w '\n' -X POST -H 'Content-type: application/json' \
-d @deploy-descriptors/deployment-descriptor-authtoken.json $OKAPI_URL/_/discovery/modules

curl -i -w '\n' -X POST -H 'Content-type: application/json' \
-d @tenant/enable-authtoken.json $OKAPI_URL/_/proxy/tenants/$TENANT_ID/modules

#circulation-storage
curl -i -w '\n' -X POST -H 'Content-type: application/json' \
-d @module-descriptors/module-circulation-storage.json $OKAPI_URL/_/proxy/modules

curl -i -w '\n' -X POST -H 'Content-type: application/json' \
-d @deploy-descriptors/deployment-descriptor-circulation-storage.json $OKAPI_URL/_/discovery/modules

curl -i -w '\n' -X POST -H 'Content-type: application/json' \
-d @tenant/enable-circulation-storage.json $OKAPI_URL/_/proxy/tenants/$TENANT_ID/modules

#circulation
curl -i -w '\n' -X POST -H 'Content-type: application/json' \
-d @module-descriptors/module-circulation.json $OKAPI_URL/_/proxy/modules

curl -i -w '\n' -X POST -H 'Content-type: application/json' \
-d @deploy-descriptors/deployment-descriptor-circulation.json $OKAPI_URL/_/discovery/modules

curl -i -w '\n' -X POST -H 'Content-type: application/json' \
-d @tenant/enable-circulation.json $OKAPI_URL/_/proxy/tenants/$TENANT_ID/modules

#inventory
curl -i -w '\n' -X POST -H 'Content-type: application/json' \
-d @module-descriptors/module-inventory.json $OKAPI_URL/_/proxy/modules

curl -i -w '\n' -X POST -H 'Content-type: application/json' \
-d @deploy-descriptors/deployment-descriptor-inventory.json $OKAPI_URL/_/discovery/modules

curl -i -w '\n' -X POST -H 'Content-type: application/json' \
-d @tenant/enable-inventory.json $OKAPI_URL/_/proxy/tenants/$TENANT_ID/modules

#codex-mux
curl -i -w '\n' -X POST -H 'Content-type: application/json' \
-d @module-descriptors/module-codex-mux.json $OKAPI_URL/_/proxy/modules

curl -i -w '\n' -X POST -H 'Content-type: application/json' \
-d @deploy-descriptors/deployment-descriptor-codex-mux.json $OKAPI_URL/_/discovery/modules

curl -i -w '\n' -X POST -H 'Content-type: application/json' \
-d @tenant/enable-codex-mux.json $OKAPI_URL/_/proxy/tenants/$TENANT_ID/modules

#codex-inventory
curl -i -w '\n' -X POST -H 'Content-type: application/json' \
-d @module-descriptors/module-codex-inventory.json $OKAPI_URL/_/proxy/modules

curl -i -w '\n' -X POST -H 'Content-type: application/json' \
-d @deploy-descriptors/deployment-descriptor-codex-inventory.json $OKAPI_URL/_/discovery/modules

curl -i -w '\n' -X POST -H 'Content-type: application/json' \
-d @tenant/enable-codex-inventory.json $OKAPI_URL/_/proxy/tenants/$TENANT_ID/modules

#login-saml
curl -i -w '\n' -X POST -H 'Content-type: application/json' \
-d @module-descriptors/module-login-saml.json $OKAPI_URL/_/proxy/modules

curl -i -w '\n' -X POST -H 'Content-type: application/json' \
-d @deploy-descriptors/deployment-descriptor-login-saml.json $OKAPI_URL/_/discovery/modules

curl -i -w '\n' -X POST -H 'Content-type: application/json' \
-d @tenant/enable-login-saml.json $OKAPI_URL/_/proxy/tenants/$TENANT_ID/modules

#notify
curl -i -w '\n' -X POST -H 'Content-type: application/json' \
-d @module-descriptors/module-notify.json $OKAPI_URL/_/proxy/modules

curl -i -w '\n' -X POST -H 'Content-type: application/json' \
-d @deploy-descriptors/deployment-descriptor-notify.json $OKAPI_URL/_/discovery/modules

curl -i -w '\n' -X POST -H 'Content-type: application/json' \
-d @tenant/enable-notify.json $OKAPI_URL/_/proxy/tenants/$TENANT_ID/modules

#notes
curl -i -w '\n' -X POST -H 'Content-type: application/json' \
-d @module-descriptors/module-notes.json $OKAPI_URL/_/proxy/modules

curl -i -w '\n' -X POST -H 'Content-type: application/json' \
-d @deploy-descriptors/deployment-descriptor-notes.json $OKAPI_URL/_/discovery/modules

curl -i -w '\n' -X POST -H 'Content-type: application/json' \
-d @tenant/enable-notes.json $OKAPI_URL/_/proxy/tenants/$TENANT_ID/modules

#users-bl
curl -i -w '\n' -X POST -H 'Content-type: application/json' \
-d @module-descriptors/module-users-bl.json $OKAPI_URL/_/proxy/modules

curl -i -w '\n' -X POST -H 'Content-type: application/json' \
-d @deploy-descriptors/deployment-descriptor-users-bl.json $OKAPI_URL/_/discovery/modules

curl -i -w '\n' -X POST -H 'Content-type: application/json' \
-d @tenant/enable-users-bl.json $OKAPI_URL/_/proxy/tenants/$TENANT_ID/modules

#tags
curl -i -w '\n' -X POST -H 'Content-type: application/json' \
-d @module-descriptors/module-tags.json $OKAPI_URL/_/proxy/modules

curl -i -w '\n' -X POST -H 'Content-type: application/json' \
-d @deploy-descriptors/deployment-descriptor-tags.json $OKAPI_URL/_/discovery/modules

curl -i -w '\n' -X POST -H 'Content-type: application/json' \
-d @tenant/enable-tags.json $OKAPI_URL/_/proxy/tenants/$TENANT_ID/modules

#codex-ekb
curl -i -w '\n' -X POST -H 'Content-type: application/json' \
-d @module-descriptors/module-codex-ekb.json $OKAPI_URL/_/proxy/modules

curl -i -w '\n' -X POST -H 'Content-type: application/json' \
-d @deploy-descriptors/deployment-descriptor-codex-ekb.json $OKAPI_URL/_/discovery/modules

curl -i -w '\n' -X POST -H 'Content-type: application/json' \
-d @tenant/enable-codex-ekb.json $OKAPI_URL/_/proxy/tenants/$TENANT_ID/modules

#kb-ebsco
curl -i -w '\n' -X POST -H 'Content-type: application/json' \
-d @module-descriptors/module-kb-ebsco.json $OKAPI_URL/_/proxy/modules

curl -i -w '\n' -X POST -H 'Content-type: application/json' \
-d @deploy-descriptors/deployment-descriptor-kb-ebsco.json $OKAPI_URL/_/discovery/modules

curl -i -w '\n' -X POST -H 'Content-type: application/json' \
-d @tenant/enable-kb-ebsco.json $OKAPI_URL/_/proxy/tenants/$TENANT_ID/modules

#calendar
curl -i -w '\n' -X POST -H 'Content-type: application/json' \
-d @module-descriptors/module-calendar.json $OKAPI_URL/_/proxy/modules

curl -i -w '\n' -X POST -H 'Content-type: application/json' \
-d @deploy-descriptors/deployment-descriptor-calendar.json $OKAPI_URL/_/discovery/modules

curl -i -w '\n' -X POST -H 'Content-type: application/json' \
-d @tenant/enable-calendar.json $OKAPI_URL/_/proxy/tenants/$TENANT_ID/modules

#vendors
curl -i -w '\n' -X POST -H 'Content-type: application/json' \
-d @module-descriptors/module-vendors.json $OKAPI_URL/_/proxy/modules

curl -i -w '\n' -X POST -H 'Content-type: application/json' \
-d @deploy-descriptors/deployment-descriptor-vendors.json $OKAPI_URL/_/discovery/modules

curl -i -w '\n' -X POST -H 'Content-type: application/json' \
-d @tenant/enable-vendors.json $OKAPI_URL/_/proxy/tenants/$TENANT_ID/modules

#agreements
#curl -i -w '\n' -X POST -H 'Content-type: application/json' \
#-d @module-descriptors/module-agreements.json $OKAPI_URL/_/proxy/modules

#curl -i -w '\n' -X POST -H 'Content-type: application/json' \
#-d @deploy-descriptors/deployment-descriptor-agreements.json $OKAPI_URL/_/discovery/modules

curl -i -w '\n' -X POST -H 'Content-type: application/json' \
-d @tenant/enable-agreements.json $OKAPI_URL/_/proxy/tenants/$TENANT_ID/modules

#marccat
curl -i -w '\n' -X POST -H 'Content-type: application/json' \
-d @module-descriptors/module-marccat.json $OKAPI_URL/_/proxy/modules

curl -i -w '\n' -X POST -H 'Content-type: application/json' \
-d @deploy-descriptors/deployment-descriptor-marccat.json $OKAPI_URL/_/discovery/modules

curl -i -w '\n' -X POST -H 'Content-type: application/json' \
-d @tenant/enable-marccat.json $OKAPI_URL/_/proxy/tenants/$TENANT_ID/modules

#template-engine
curl -i -w '\n' -X POST -H 'Content-type: application/json' \
-d @module-descriptors/module-template-engine.json $OKAPI_URL/_/proxy/modules

curl -i -w '\n' -X POST -H 'Content-type: application/json' \
-d @deploy-descriptors/deployment-descriptor-template-engine.json $OKAPI_URL/_/discovery/modules

curl -i -w '\n' -X POST -H 'Content-type: application/json' \
-d @tenant/enable-template-engine.json $OKAPI_URL/_/proxy/tenants/$TENANT_ID/modules

#finance-storage
curl -i -w '\n' -X POST -H 'Content-type: application/json' \
-d @module-descriptors/module-finance-storage.json $OKAPI_URL/_/proxy/modules

curl -i -w '\n' -X POST -H 'Content-type: application/json' \
-d @deploy-descriptors/deployment-descriptor-finance-storage.json $OKAPI_URL/_/discovery/modules

curl -i -w '\n' -X POST -H 'Content-type: application/json' \
-d @tenant/enable-finance-storage.json $OKAPI_URL/_/proxy/tenants/$TENANT_ID/modules

#orders-storage
curl -i -w '\n' -X POST -H 'Content-type: application/json' \
-d @module-descriptors/module-orders-storage.json $OKAPI_URL/_/proxy/modules

curl -i -w '\n' -X POST -H 'Content-type: application/json' \
-d @deploy-descriptors/deployment-descriptor-orders-storage.json $OKAPI_URL/_/discovery/modules

curl -i -w '\n' -X POST -H 'Content-type: application/json' \
-d @tenant/enable-orders-storage.json $OKAPI_URL/_/proxy/tenants/$TENANT_ID/modules

#source-record-storage
curl -i -w '\n' -X POST -H 'Content-type: application/json' \
-d @module-descriptors/module-source-record-storage.json $OKAPI_URL/_/proxy/modules

curl -i -w '\n' -X POST -H 'Content-type: application/json' \
-d @deploy-descriptors/deployment-descriptor-source-record-storage.json $OKAPI_URL/_/discovery/modules

curl -i -w '\n' -X POST -H 'Content-type: application/json' \
-d @tenant/enable-source-record-storage.json $OKAPI_URL/_/proxy/tenants/$TENANT_ID/modules

#source-record-manager
curl -i -w '\n' -X POST -H 'Content-type: application/json' \
-d @module-descriptors/module-source-record-manager.json $OKAPI_URL/_/proxy/modules

curl -i -w '\n' -X POST -H 'Content-type: application/json' \
-d @deploy-descriptors/deployment-descriptor-source-record-manager.json $OKAPI_URL/_/discovery/modules

curl -i -w '\n' -X POST -H 'Content-type: application/json' \
-d @tenant/enable-source-record-manager.json $OKAPI_URL/_/proxy/tenants/$TENANT_ID/modules

#event-config
curl -i -w '\n' -X POST -H 'Content-type: application/json' \
-d @module-descriptors/module-event-config.json $OKAPI_URL/_/proxy/modules

curl -i -w '\n' -X POST -H 'Content-type: application/json' \
-d @deploy-descriptors/deployment-descriptor-event-config.json $OKAPI_URL/_/discovery/modules

curl -i -w '\n' -X POST -H 'Content-type: application/json' \
-d @tenant/enable-event-config.json $OKAPI_URL/_/proxy/tenants/$TENANT_ID/modules

#orders
curl -i -w '\n' -X POST -H 'Content-type: application/json' \
-d @module-descriptors/module-orders.json $OKAPI_URL/_/proxy/modules

curl -i -w '\n' -X POST -H 'Content-type: application/json' \
-d @deploy-descriptors/deployment-descriptor-orders.json $OKAPI_URL/_/discovery/modules

curl -i -w '\n' -X POST -H 'Content-type: application/json' \
-d @tenant/enable-orders.json $OKAPI_URL/_/proxy/tenants/$TENANT_ID/modules

#erm-usage
curl -i -w '\n' -X POST -H 'Content-type: application/json' \
-d @module-descriptors/module-erm-usage.json $OKAPI_URL/_/proxy/modules

curl -i -w '\n' -X POST -H 'Content-type: application/json' \
-d @deploy-descriptors/deployment-descriptor-erm-usage.json $OKAPI_URL/_/discovery/modules

curl -i -w '\n' -X POST -H 'Content-type: application/json' \
-d @tenant/enable-erm-usage.json $OKAPI_URL/_/proxy/tenants/$TENANT_ID/modules

#erm-usage-harvester
curl -i -w '\n' -X POST -H 'Content-type: application/json' \
-d @module-descriptors/module-erm-usage-harvester.json $OKAPI_URL/_/proxy/modules

curl -i -w '\n' -X POST -H 'Content-type: application/json' \
-d @deploy-descriptors/deployment-descriptor-erm-usage-harvester.json $OKAPI_URL/_/discovery/modules

curl -i -w '\n' -X POST -H 'Content-type: application/json' \
-d @tenant/enable-erm-usage-harvester.json $OKAPI_URL/_/proxy/tenants/$TENANT_ID/modules

#gobi
curl -i -w '\n' -X POST -H 'Content-type: application/json' \
-d @module-descriptors/module-gobi.json $OKAPI_URL/_/proxy/modules

curl -i -w '\n' -X POST -H 'Content-type: application/json' \
-d @deploy-descriptors/deployment-descriptor-gobi.json $OKAPI_URL/_/discovery/modules

curl -i -w '\n' -X POST -H 'Content-type: application/json' \
-d @tenant/enable-gobi.json $OKAPI_URL/_/proxy/tenants/$TENANT_ID/modules

#data-import
curl -i -w '\n' -X POST -H 'Content-type: application/json' \
-d @module-descriptors/module-data-import.json $OKAPI_URL/_/proxy/modules

curl -i -w '\n' -X POST -H 'Content-type: application/json' \
-d @deploy-descriptors/deployment-descriptor-data-import.json $OKAPI_URL/_/discovery/modules

curl -i -w '\n' -X POST -H 'Content-type: application/json' \
-d @tenant/enable-data-import.json $OKAPI_URL/_/proxy/tenants/$TENANT_ID/modules

#patron
curl -i -w '\n' -X POST -H 'Content-type: application/json' \
-d @module-descriptors/module-patron.json $OKAPI_URL/_/proxy/modules

curl -i -w '\n' -X POST -H 'Content-type: application/json' \
-d @deploy-descriptors/deployment-descriptor-patron.json $OKAPI_URL/_/discovery/modules

curl -i -w '\n' -X POST -H 'Content-type: application/json' \
-d @tenant/enable-patron.json $OKAPI_URL/_/proxy/tenants/$TENANT_ID/modules

#rtac
curl -i -w '\n' -X POST -H 'Content-type: application/json' \
-d @module-descriptors/module-rtac.json $OKAPI_URL/_/proxy/modules

curl -i -w '\n' -X POST -H 'Content-type: application/json' \
-d @deploy-descriptors/deployment-descriptor-rtac.json $OKAPI_URL/_/discovery/modules

curl -i -w '\n' -X POST -H 'Content-type: application/json' \
-d @tenant/enable-rtac.json $OKAPI_URL/_/proxy/tenants/$TENANT_ID/modules

#email
curl -i -w '\n' -X POST -H 'Content-type: application/json' \
-d @module-descriptors/module-email.json $OKAPI_URL/_/proxy/modules

curl -i -w '\n' -X POST -H 'Content-type: application/json' \
-d @deploy-descriptors/deployment-descriptor-email.json $OKAPI_URL/_/discovery/modules

curl -i -w '\n' -X POST -H 'Content-type: application/json' \
-d @tenant/enable-email.json $OKAPI_URL/_/proxy/tenants/$TENANT_ID/modules

#sender
curl -i -w '\n' -X POST -H 'Content-type: application/json' \
-d @module-descriptors/module-sender.json $OKAPI_URL/_/proxy/modules

curl -i -w '\n' -X POST -H 'Content-type: application/json' \
-d @deploy-descriptors/deployment-descriptor-sender.json $OKAPI_URL/_/discovery/modules

curl -i -w '\n' -X POST -H 'Content-type: application/json' \
-d @tenant/enable-sender.json $OKAPI_URL/_/proxy/tenants/$TENANT_ID/modules

#audit
curl -i -w '\n' -X POST -H 'Content-type: application/json' \
-d @module-descriptors/module-audit.json $OKAPI_URL/_/proxy/modules

curl -i -w '\n' -X POST -H 'Content-type: application/json' \
-d @deploy-descriptors/deployment-descriptor-audit.json $OKAPI_URL/_/discovery/modules

curl -i -w '\n' -X POST -H 'Content-type: application/json' \
-d @tenant/enable-audit.json $OKAPI_URL/_/proxy/tenants/$TENANT_ID/modules

#audit-filter
curl -i -w '\n' -X POST -H 'Content-type: application/json' \
-d @module-descriptors/module-audit-filter.json $OKAPI_URL/_/proxy/modules

curl -i -w '\n' -X POST -H 'Content-type: application/json' \
-d @deploy-descriptors/deployment-descriptor-audit-filter.json $OKAPI_URL/_/discovery/modules

curl -i -w '\n' -X POST -H 'Content-type: application/json' \
-d @tenant/enable-audit-filter.json $OKAPI_URL/_/proxy/tenants/$TENANT_ID/modules

#licenses
#curl -i -w '\n' -X POST -H 'Content-type: application/json' \
#-d @module-descriptors/module-licenses.json $OKAPI_URL/_/proxy/modules

#curl -i -w '\n' -X POST -H 'Content-type: application/json' \
#-d @deploy-descriptors/deployment-descriptor-licenses.json $OKAPI_URL/_/discovery/modules

curl -i -w '\n' -X POST -H 'Content-type: application/json' \
-d @tenant/enable-licenses.json $OKAPI_URL/_/proxy/tenants/$TENANT_ID/modules

#oai-pmh
curl -i -w '\n' -X POST -H 'Content-type: application/json' \
-d @module-descriptors/module-oai-pmh.json $OKAPI_URL/_/proxy/modules

curl -i -w '\n' -X POST -H 'Content-type: application/json' \
-d @deploy-descriptors/deployment-descriptor-oai-pmh.json $OKAPI_URL/_/discovery/modules

curl -i -w '\n' -X POST -H 'Content-type: application/json' \
-d @tenant/enable-oai-pmh.json $OKAPI_URL/_/proxy/tenants/$TENANT_ID/modules

#user-import
curl -i -w '\n' -X POST -H 'Content-type: application/json' \
-d @module-descriptors/module-user-import.json $OKAPI_URL/_/proxy/modules

curl -i -w '\n' -X POST -H 'Content-type: application/json' \
-d @deploy-descriptors/deployment-descriptor-user-import.json $OKAPI_URL/_/discovery/modules

curl -i -w '\n' -X POST -H 'Content-type: application/json' \
-d @tenant/enable-user-import.json $OKAPI_URL/_/proxy/tenants/$TENANT_ID/modules

#graphql
curl -i -w '\n' -X POST -H 'Content-type: application/json' \
-d @module-descriptors/module-graphql.json $OKAPI_URL/_/proxy/modules

curl -i -w '\n' -X POST -H 'Content-type: application/json' \
-d @deploy-descriptors/deployment-descriptor-graphql.json $OKAPI_URL/_/discovery/modules

curl -i -w '\n' -X POST -H 'Content-type: application/json' \
-d @tenant/enable-graphql.json $OKAPI_URL/_/proxy/tenants/$TENANT_ID/modules

#data-loader
curl -i -w '\n' -X POST -H 'Content-type: application/json' \
-d @module-descriptors/module-data-loader.json $OKAPI_URL/_/proxy/modules

curl -i -w '\n' -X POST -H 'Content-type: application/json' \
-d @deploy-descriptors/deployment-descriptor-data-loader.json $OKAPI_URL/_/discovery/modules

curl -i -w '\n' -X POST -H 'Content-type: application/json' \
-d @tenant/enable-data-loader.json $OKAPI_URL/_/proxy/tenants/$TENANT_ID/modules


# Register Stripes front-end

#!/bin/sh

#stripes-core
curl -i -w '\n' -X POST -H 'Content-type: application/json' \
-d @stripes/module-descriptors/stripes-core.json $OKAPI_URL/_/proxy/modules

curl -i -w '\n' -X POST -H 'Content-type: application/json' \
-d @stripes/tenant/stripes-core.json $OKAPI_URL/_/proxy/tenants/$TENANT_ID/modules

#checkin
curl -i -w '\n' -X POST -H 'Content-type: application/json' \
-d @stripes/module-descriptors/checkin.json $OKAPI_URL/_/proxy/modules

curl -i -w '\n' -X POST -H 'Content-type: application/json' \
-d @stripes/tenant/checkin.json $OKAPI_URL/_/proxy/tenants/$TENANT_ID/modules

#checkout
curl -i -w '\n' -X POST -H 'Content-type: application/json' \
-d @stripes/module-descriptors/checkout.json $OKAPI_URL/_/proxy/modules

curl -i -w '\n' -X POST -H 'Content-type: application/json' \
-d @stripes/tenant/checkout.json $OKAPI_URL/_/proxy/tenants/$TENANT_ID/modules

#circulation
curl -i -w '\n' -X POST -H 'Content-type: application/json' \
-d @stripes/module-descriptors/circulation.json $OKAPI_URL/_/proxy/modules

curl -i -w '\n' -X POST -H 'Content-type: application/json' \
-d @stripes/tenant/circulation.json $OKAPI_URL/_/proxy/tenants/$TENANT_ID/modules

#developer
curl -i -w '\n' -X POST -H 'Content-type: application/json' \
-d @stripes/module-descriptors/developer.json $OKAPI_URL/_/proxy/modules

curl -i -w '\n' -X POST -H 'Content-type: application/json' \
-d @stripes/tenant/developer.json $OKAPI_URL/_/proxy/tenants/$TENANT_ID/modules

#inventory
curl -i -w '\n' -X POST -H 'Content-type: application/json' \
-d @stripes/module-descriptors/inventory.json $OKAPI_URL/_/proxy/modules

curl -i -w '\n' -X POST -H 'Content-type: application/json' \
-d @stripes/tenant/inventory.json $OKAPI_URL/_/proxy/tenants/$TENANT_ID/modules

#myprofile
curl -i -w '\n' -X POST -H 'Content-type: application/json' \
-d @stripes/module-descriptors/myprofile.json $OKAPI_URL/_/proxy/modules

curl -i -w '\n' -X POST -H 'Content-type: application/json' \
-d @stripes/tenant/myprofile.json $OKAPI_URL/_/proxy/tenants/$TENANT_ID/modules

#organization
curl -i -w '\n' -X POST -H 'Content-type: application/json' \
-d @stripes/module-descriptors/organization.json $OKAPI_URL/_/proxy/modules

curl -i -w '\n' -X POST -H 'Content-type: application/json' \
-d @stripes/tenant/organization.json $OKAPI_URL/_/proxy/tenants/$TENANT_ID/modules

#plugin-find-instance
curl -i -w '\n' -X POST -H 'Content-type: application/json' \
-d @stripes/module-descriptors/plugin-find-instance.json $OKAPI_URL/_/proxy/modules

curl -i -w '\n' -X POST -H 'Content-type: application/json' \
-d @stripes/tenant/plugin-find-instance.json $OKAPI_URL/_/proxy/tenants/$TENANT_ID/modules

#plugin-find-user
curl -i -w '\n' -X POST -H 'Content-type: application/json' \
-d @stripes/module-descriptors/plugin-find-user.json $OKAPI_URL/_/proxy/modules

curl -i -w '\n' -X POST -H 'Content-type: application/json' \
-d @stripes/tenant/plugin-find-user.json $OKAPI_URL/_/proxy/tenants/$TENANT_ID/modules

#requests
curl -i -w '\n' -X POST -H 'Content-type: application/json' \
-d @stripes/module-descriptors/requests.json $OKAPI_URL/_/proxy/modules

curl -i -w '\n' -X POST -H 'Content-type: application/json' \
-d @stripes/tenant/requests.json $OKAPI_URL/_/proxy/tenants/$TENANT_ID/modules

#search
curl -i -w '\n' -X POST -H 'Content-type: application/json' \
-d @stripes/module-descriptors/search.json $OKAPI_URL/_/proxy/modules

curl -i -w '\n' -X POST -H 'Content-type: application/json' \
-d @stripes/tenant/search.json $OKAPI_URL/_/proxy/tenants/$TENANT_ID/modules

#servicepoints
curl -i -w '\n' -X POST -H 'Content-type: application/json' \
-d @stripes/module-descriptors/servicepoints.json $OKAPI_URL/_/proxy/modules

curl -i -w '\n' -X POST -H 'Content-type: application/json' \
-d @stripes/tenant/servicepoints.json $OKAPI_URL/_/proxy/tenants/$TENANT_ID/modules

#stripes-smart-components
curl -i -w '\n' -X POST -H 'Content-type: application/json' \
-d @stripes/module-descriptors/stripes-smart-components.json $OKAPI_URL/_/proxy/modules

curl -i -w '\n' -X POST -H 'Content-type: application/json' \
-d @stripes/tenant/stripes-smart-components.json $OKAPI_URL/_/proxy/tenants/$TENANT_ID/modules

#tags
curl -i -w '\n' -X POST -H 'Content-type: application/json' \
-d @stripes/module-descriptors/tags.json $OKAPI_URL/_/proxy/modules

curl -i -w '\n' -X POST -H 'Content-type: application/json' \
-d @stripes/tenant/tags.json $OKAPI_URL/_/proxy/tenants/$TENANT_ID/modules

#users
curl -i -w '\n' -X POST -H 'Content-type: application/json' \
-d @stripes/module-descriptors/users.json $OKAPI_URL/_/proxy/modules

curl -i -w '\n' -X POST -H 'Content-type: application/json' \
-d @stripes/tenant/users.json $OKAPI_URL/_/proxy/tenants/$TENANT_ID/modules

#agreements
curl -i -w '\n' -X POST -H 'Content-type: application/json' \
-d @stripes/module-descriptors/agreements.json $OKAPI_URL/_/proxy/modules

curl -i -w '\n' -X POST -H 'Content-type: application/json' \
-d @stripes/tenant/agreements.json $OKAPI_URL/_/proxy/tenants/$TENANT_ID/modules

#calendar
curl -i -w '\n' -X POST -H 'Content-type: application/json' \
-d @stripes/module-descriptors/calendar.json $OKAPI_URL/_/proxy/modules

curl -i -w '\n' -X POST -H 'Content-type: application/json' \
-d @stripes/tenant/calendar.json $OKAPI_URL/_/proxy/tenants/$TENANT_ID/modules

#data-import
curl -i -w '\n' -X POST -H 'Content-type: application/json' \
-d @stripes/module-descriptors/data-import.json $OKAPI_URL/_/proxy/modules

curl -i -w '\n' -X POST -H 'Content-type: application/json' \
-d @stripes/tenant/data-import.json $OKAPI_URL/_/proxy/tenants/$TENANT_ID/modules

#eHoldings
curl -i -w '\n' -X POST -H 'Content-type: application/json' \
-d @stripes/module-descriptors/eholdings.json $OKAPI_URL/_/proxy/modules

curl -i -w '\n' -X POST -H 'Content-type: application/json' \
-d @stripes/tenant/eholdings.json $OKAPI_URL/_/proxy/tenants/$TENANT_ID/modules

#erm-usage
curl -i -w '\n' -X POST -H 'Content-type: application/json' \
-d @stripes/module-descriptors/erm-usage.json $OKAPI_URL/_/proxy/modules

curl -i -w '\n' -X POST -H 'Content-type: application/json' \
-d @stripes/tenant/erm-usage.json $OKAPI_URL/_/proxy/tenants/$TENANT_ID/modules

#finance
curl -i -w '\n' -X POST -H 'Content-type: application/json' \
-d @stripes/module-descriptors/finance.json $OKAPI_URL/_/proxy/modules

curl -i -w '\n' -X POST -H 'Content-type: application/json' \
-d @stripes/tenant/finance.json $OKAPI_URL/_/proxy/tenants/$TENANT_ID/modules

#licenses
curl -i -w '\n' -X POST -H 'Content-type: application/json' \
-d @stripes/module-descriptors/licenses.json $OKAPI_URL/_/proxy/modules

curl -i -w '\n' -X POST -H 'Content-type: application/json' \
-d @stripes/tenant/licenses.json $OKAPI_URL/_/proxy/tenants/$TENANT_ID/modules

#marccat
curl -i -w '\n' -X POST -H 'Content-type: application/json' \
-d @stripes/module-descriptors/marccat.json $OKAPI_URL/_/proxy/modules

curl -i -w '\n' -X POST -H 'Content-type: application/json' \
-d @stripes/tenant/marccat.json $OKAPI_URL/_/proxy/tenants/$TENANT_ID/modules

#orders
curl -i -w '\n' -X POST -H 'Content-type: application/json' \
-d @stripes/module-descriptors/orders.json $OKAPI_URL/_/proxy/modules

curl -i -w '\n' -X POST -H 'Content-type: application/json' \
-d @stripes/tenant/orders.json $OKAPI_URL/_/proxy/tenants/$TENANT_ID/modules

#vendors
curl -i -w '\n' -X POST -H 'Content-type: application/json' \
-d @stripes/module-descriptors/vendors.json $OKAPI_URL/_/proxy/modules

curl -i -w '\n' -X POST -H 'Content-type: application/json' \
-d @stripes/tenant/vendors.json $OKAPI_URL/_/proxy/tenants/$TENANT_ID/modules

#plugin-find-vendor
curl -i -w '\n' -X POST -H 'Content-type: application/json' \
-d @stripes/module-descriptors/plugin-find-vendor.json $OKAPI_URL/_/proxy/modules

curl -i -w '\n' -X POST -H 'Content-type: application/json' \
-d @stripes/tenant/plugin-find-vendor.json $OKAPI_URL/_/proxy/tenants/$TENANT_ID/modules


