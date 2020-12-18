### Module Metadata

### Database connection envs:
DB_DATABASE = okapi_modules<br/>
DB_HOST = postgres_host<br/>
DB_MAXPOOLSIZE = 50<br/>
DB_PASSWORD = folio_admin_password<br/>
DB_PORT = 5432<br/>
DB_USERNAME = folio_admin

### edge-oai-pmh
Startup Options:<br/>
JAVA_OPTIONS = -Dokapi_url=http://okapi:9130 -Dsecure_store=Ephemeral -Dsecure_store_props=/etc/folio/edge/edge-ephemeral.properties -XX:MaxRAMPercentage=66.0<br/>
Database connection: No<br/>
Port: 8081<br/>
Health Check endpoint: /admin/health

### edge-orders
Startup Options:<br/>
JAVA_OPTIONS = -Dokapi_url=http://okapi:9130 -Dsecure_store=Ephemeral -Dsecure_store_props=/etc/folio/edge/edge-ephemeral.properties -Xmx512m<br/>
Database connection: No<br/>
Port: 8081<br/>
Health Check endpoint: /admin/health

### edge-patron
Startup Options:<br/>
JAVA_OPTIONS = -Dokapi_url=http://okapi:9130 -Dsecure_store=Ephemeral -Dsecure_store_props=/etc/folio/edge/edge-ephemeral.properties -Xmx512m<br/>
Database connection: No<br/>
Port: 8081<br/>
Health Check endpoint: NA

### edge-rtac
Startup Options:<br/>
JAVA_OPTIONS = -Dokapi_url=http://okapi:9130 -Dsecure_store=Ephemeral -Dsecure_store_props=/etc/folio/edge/edge-ephemeral.properties -Xmx512m<br/>
Database connection: No<br/>
Port: 8081<br/>
Health Check endpoint: /admin/health

### edge-sip2
Startup Options:<br/>
JAVA_OPTIONS = -Xmx512m -Dloglevel=debug<br/>
Database connection: No<br/>
Port: 6443<br/>
Health Check endpoint: NA
Docker Command: -conf '{"errorDetectionEnabled":true,"charset":"UTF8","port":80,"okapiUrl":"http://okapi-url.org","tenant":"tenantid"}'

### mod-agreements
Startup Options:<br/>
JAVA_OPTIONS = -server -XX:+UseContainerSupport -XX:MaxRAMPercentage=50.0 -XX:+PrintFlagsFinal<br/>
GRAILS_SERVER_PORT = 8080<br/>
GRAILS_SERVER_HOST = mod-agreements<br/>
Database connection: Yes<br/>
Port: 8080<br/>
Health Check endpoint: NA

### mod-authtoken
Startup Options:<br/>
JAVA_OPTIONS = -Djwt.signing.key=foo -XX:MaxRAMPercentage=66.0 -Dcache.permissions=true-Dcache.permissions=true<br/>
Database connection: No<br/>
Port: 8081<br/>
Health Check endpoint: NA

### mod-calendar
Startup Options:<br/>
JAVA_OPTIONS = -XX:MaxRAMPercentage=66.0<br/>
Database connection: Yes<br/>
Port: 8081<br/>
Health Check endpoint: /admin/health

### mod-circulation
Startup Options:<br/>
JAVA_OPTIONS = -XX:MaxRAMPercentage=66.0<br/>
Database connection: No<br/>
Port: 9801<br/>
Health Check endpoint: NA

### mod-circulation-storage
Startup Options:<br/>
JAVA_OPTIONS = -XX:MaxRAMPercentage=66.0<br/>
Database connection: Yes<br/>
Port: 8081<br/>
Health Check endpoint: /admin/health

### mod-codex-ekb
Startup Options:<br/>
JAVA_OPTIONS = -XX:MaxRAMPercentage=66.0<br/>
Database connection: No<br/>
Port: 8081<br/>
Health Check endpoint: /admin/health

### mod-codex-inventory
Startup Options:<br/>
JAVA_OPTIONS = -Xmx1024m<br/>
Database connection: No<br/>
Port: 8081<br/>
Health Check endpoint: /admin/health

### mod-codex-mux
Startup Options:<br/>
JAVA_OPTIONS = -XX:MaxRAMPercentage=66.0<br/>
Database connection: No<br/>
Port: 8081<br/>
Health Check endpoint: /admin/health

### mod-configuration
Startup Options:<br/>
JAVA_OPTIONS = -XX:MaxRAMPercentage=66.0<br/>
Database connection: Yes<br/>
Port: 8081<br/>
Health Check endpoint: /admin/health

### mod-data-import
Startup Options:<br/>
JAVA_OPTIONS = -XX:MaxRAMPercentage=66.0<br/>
Database connection: Yes<br/>
Port: 8081<br/>
Health Check endpoint: /admin/health

### mod-data-import-converter-storage
Startup Options:<br/>
JAVA_OPTIONS = -XX:MaxRAMPercentage=66.0<br/>
test.mode = false<br/>
Database connection: Yes<br/>
Port: 8081<br/>
Health Check endpoint: /admin/health

### mod-email
Startup Options:<br/>
JAVA_OPTIONS = -XX:MaxRAMPercentage=66.0<br/>
Database connection: Yes<br/>
Port: 8081<br/>
Health Check endpoint: /admin/health

### mod-erm-usage
Startup Options:<br/>
JAVA_OPTIONS = -XX:MaxRAMPercentage=66.0<br/>
Database connection: Yes<br/>
Port: 8081<br/>
Health Check endpoint: /admin/health

### mod-erm-usage-harvester
Startup Options:<br/>
JAVA_OPTIONS = -XX:MaxRAMPercentage=66.0<br/>
CONFIG = {"okapiUrl": "http://okapi:9130"}<br/>
Database connection: No<br/>
Port: 8081<br/>
Health Check endpoint: NA

### mod-event-config
Startup Options:<br/>
JAVA_OPTIONS = -XX:MaxRAMPercentage=66.0<br/>
Database connection: Yes<br/>
Port: 8081<br/>
Health Check endpoint: /admin/health

### mod-feesfines
Startup Options:<br/>
JAVA_OPTIONS = -Xmx512m<br/>
Database connection: Yes<br/>
Port: 8081<br/>
Health Check endpoint: /admin/health

### mod-finance
Startup Options:<br/>
JAVA_OPTIONS = -XX:MaxRAMPercentage=66.0<br/>
Database connection: No<br/>
Port: 8081<br/>
Health Check endpoint: /admin/health

### mod-finance-storage
Startup Options:<br/>
JAVA_OPTIONS = -XX:MaxRAMPercentage=66.0<br/>
Database connection: Yes<br/>
Port: 8081<br/>
Health Check endpoint: /admin/health

### mod-gobi
Startup Options:<br/>
JAVA_OPTIONS = -XX:MaxRAMPercentage=66.0<br/>
Database connection: No<br/>
Port: 8081<br/>
Health Check endpoint: /admin/health

### mod-graphql
Startup Options:<br/>
OKAPI_URL = http://okapi:9130<br/>
OKAPI_TOKEN = foo<br/>
OKAPI_TENANT = tamu<br/>
LOGGING_CATEGORIES = ramlpath<br/>
Database connection: No<br/>
Port: 3001<br/>
Health Check endpoint: NA

### mod-inventory
Startup Options:<br/>
JAVA_OPTIONS = -XX:MaxRAMPercentage=66.0 -Dorg.folio.metadata.inventory.storage.type=okapi<br/>
Database connection: No<br/>
Port: 9403<br/>
Health Check endpoint: NA

### mod-inventory-storage
Startup Options:<br/>
JAVA_OPTIONS = -XX:MaxRAMPercentage=66.0<br/>
Database connection: Yes<br/>
Port: 8081<br/>
Health Check endpoint: /admin/health

### mod-invoice
Startup Options:<br/>
JAVA_OPTIONS = -XX:MaxRAMPercentage=66.0<br/>
EBSCO_RMAPI_BASE_URL = https://sandbox.ebsco.io<br/>
Database connection: No<br/>
Port: 8081<br/>
Health Check endpoint: /admin/health

### mod-invoice-storage
Startup Options:<br/>
JAVA_OPTIONS = -XX:MaxRAMPercentage=66.0<br/>
Database connection: Yes<br/>
Port: 8081<br/>
Health Check endpoint: /admin/health

### mod-kb-ebsco-java
Startup Options:<br/>
JAVA_OPTIONS = -XX:+UnlockExperimentalVMOptions -XX:+UseCGroupMemoryLimitForHeap<br/>
EBSCO_RMAPI_BASE_URL = https://sandbox.ebsco.io<br/>
Database connection: Yes<br/>
Port: 8081<br/>
Health Check endpoint: /admin/health

### mod-licenses
Startup Options:<br/>
JAVA_OPTIONS = -server -XX:+UseContainerSupport -XX:MaxRAMPercentage=50.0 -XX:+PrintFlagsFinal<br/>
GRAILS_SERVER_PORT = 8080<br/>
GRAILS_SERVER_HOST = mod-licenses-2-0-0<br/>
Database connection: Yes<br/>
Port: 8080<br/>
Health Check endpoint: NA

### mod-login
Startup Options:<br/>
JAVA_OPTIONS = -XX:MaxRAMPercentage=66.0<br/>
Database connection: Yes<br/>
Port: 8081<br/>
Health Check endpoint: /admin/health<br/>
Docker Command: verify.user=true

### mod-login-saml
Startup Options:<br/>
JAVA_OPTIONS = -Xmx512m<br/>
Database connection: No<br/>
Port: 8081<br/>
Health Check endpoint: /admin/health

### mod-notes
Startup Options:<br/>
JAVA_OPTIONS = -XX:MaxRAMPercentage=66.0<br/>
Database connection: Yes<br/>
Port: 8081<br/>
Health Check endpoint: /admin/health

### mod-notify
Startup Options:<br/>
JAVA_OPTIONS = -XX:MaxRAMPercentage=66.0<br/>
Database connection: Yes<br/>
Port: 8081<br/>
Health Check endpoint: /admin/health

### mod-oai-pmh
Startup Options:<br/>
JAVA_OPTIONS = -XX:MaxRAMPercentage=66.0<br/>
Database connection: No<br/>
Port: 8081<br/>
Health Check endpoint: /admin/health

### mod-orders
Startup Options:<br/>
JAVA_OPTIONS = -XX:MaxRAMPercentage=66.0<br/>
Database connection: No<br/>
Port: 8081<br/>
Health Check endpoint: /admin/health

### mod-orders-storage
Startup Options:<br/>
JAVA_OPTIONS = -XX:MaxRAMPercentage=66.0<br/>
Database connection: Yes<br/>
Port: 8081<br/>
Health Check endpoint: /admin/health

### mod-organizations-storage
Startup Options:<br/>
JAVA_OPTIONS = -XX:MaxRAMPercentage=66.0<br/>
Database connection: Yes<br/>
Port: 8081<br/>
Health Check endpoint: /admin/health

### mod-password-validator
Startup Options:<br/>
JAVA_OPTIONS = -XX:MaxRAMPercentage=66.0<br/>
Database connection: Yes<br/>
Port: 8081<br/>
Health Check endpoint: /admin/health

### mod-patron
Startup Options:<br/>
JAVA_OPTIONS = -XX:MaxRAMPercentage=66.0<br/>
Database connection: No<br/>
Port: 8081<br/>
Health Check endpoint: /admin/health

### mod-permissions
Startup Options:<br/>
JAVA_OPTIONS = -XX:MaxRAMPercentage=66.0<br/>
Database connection: Yes<br/>
Port: 8081<br/>
Health Check endpoint: /admin/health

### mod-rtac
Startup Options:<br/>
JAVA_OPTIONS = -XX:MaxRAMPercentage=66.0<br/>
Database connection: No<br/>
Port: 8081<br/>
Health Check endpoint: /admin/health

### mod-sender
Startup Options:<br/>
JAVA_OPTIONS = -XX:MaxRAMPercentage=66.0<br/>
Database connection: Yes<br/>
Port: 8081<br/>
Health Check endpoint: /admin/health

### mod-source-record-manager
Startup Options:<br/>
JAVA_OPTIONS = -XX:MaxRAMPercentage=66.0<br/>
test.mode = true<br/>
Database connection: Yes<br/>
Port: 8081<br/>
Health Check endpoint: /admin/health

### mod-source-record-storage
Startup Options:<br/>
JAVA_OPTIONS = -XX:MaxRAMPercentage=66.0<br/>
test.mode = false<br/>
Database connection: Yes<br/>
Port: 8081<br/>
Health Check endpoint: /admin/health

### mod-tags
Startup Options:<br/>
JAVA_OPTIONS = -XX:MaxRAMPercentage=66.0<br/>
Database connection: Yes<br/>
Port: 8081<br/>
Health Check endpoint: /admin/health

### mod-template-engine
Startup Options:<br/>
JAVA_OPTIONS = -XX:MaxRAMPercentage=66.0<br/>
Database connection: Yes<br/>
Port: 8081<br/>
Health Check endpoint: /admin/health<br/>
Docker Command: verify.user=true

### mod-user-import
Startup Options:<br/>
JAVA_OPTIONS = -Xmx2048m<br/>
Database connection: No<br/>
Port: 8081<br/>
Health Check endpoint: /admin/health

### mod-users
Startup Options:<br/>
JAVA_OPTIONS = -XX:MaxRAMPercentage=66.0<br/>
Database connection: Yes<br/>
Port: 8081<br/>
Health Check endpoint: /admin/health

### mod-users-bl
Startup Options:<br/>
JAVA_OPTIONS = -XX:MaxRAMPercentage=66.0<br/>
Database connection: No<br/>
Port: 8081<br/>
Health Check endpoint: /admin/health
