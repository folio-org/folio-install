# Installing Edge Modules
Begin by collecting information about the edge module you are installing. In this example, we'll install edge-oai-pmh. Collect information on your own environment following the example below:
| Variable | Example Value | Notes |
|----------|-------|------|
| Institutional User | instuser | username of your choosing |
| Instituitonal User Password | instpass | password of your choosing |
| Tenant | diku | | 
| Permission sets | oai-pmh.all | permissions to be assigned to institutional user |

## Create institutional user
An institutional must be created with appropriate permissions to use the edge module. You can use the included `create-user.py` script to create a user and assign permissions if you choose.
```
./create-user.py -u instuser -p instpass \
    --permissions oai-pmh.all --tenant diku \
    --admin-user diku_admin --admin-password admin
```
If you need to assign more than one permission set, use a comma delimeted list, i.e. `--permissions edge-rtac.all,edge-oai-pmh.all`.
### Create an Edge API key
Refer to the documentation in the [edge-common](https://github.com/folio-org/edge-common) repository for more details on how to create an API key for a production ready system. For this example, we'll use an `ephemeral.properties` file which stores credentials in plain text. This is meant for development and demonstration purposes only.
```
cd ~
git clone https://github.com/folio-org/edge-common.git
cd edge-common
mvn package
java -jar target/edge-common-api-key-utils.jar -g -t diku -u instuser
```


## Start edge module Docker containers
You can run containers for edge modules in a number of ways. This guide uses docker-compose.
### Set up ephemeral.properties file
```
sudo mkdir -p /etc/folio/edge
vi /etc/folio/edge/edge-oai-pmh-ephemeral.properties
```
The ephemeral properties file should look like this
```
secureStore.type=Ephemeral
# a comma separated list of tenants
tenants=diku
#######################################################
# For each tenant, the institutional user password...
#
# Note: this is intended for development purposes only
#######################################################
# format: tenant=username,password
diku=instuser,instpass
```
### Set up a docker compose file
Set up a docker compose file in `/etc/folio/edge/docker-compose.yml` that defines each edge module you want to run as a service. For example, we'll define a service for edge-oai-pmh here.
```
version: '2'
services:
  edge-oai-pmh:
    ports: 
      - "9700:8081"
    image: folioci/edge-oai-pmh:2.1.0-SNAPSHOT.24
    volumes: 
      - /etc/folio/edge:/mnt
    command: 
      -"-Dokapi_url=http://localhost:9130"
      -"-Dsecure_store_props=/mnt/edge-oai-pmh-ephemeral.properties"
    restart: "always"
```
To start the edge module containers:
```
cd /etc/folio/edge
sudo docker-compose up -d
```
## Set up Nginx
```
sudo apt update
sudo apt install nginx -y
```
Now disable the default virtual host config and create a new one to proxy the edge modules.
```
sudo unlink /etc/nginx/sites-enabled/default
sudo vi /etc/nginx/sites-available/edge
```
Configure your Nginx to proxy your edge modules. In this example, we'll configure edge-oai-pmh.
```
server {
  listen 8000;
  server_name localhost;
  charset utf-8;
  
  location /oai {
      proxy_pass http://localhost:9700;
  }
}
```
In this configuration, nginx is listening on port 8000 which is an arbitrary unused port selected to listen for requests to edge APIs. The location `/oai` is based on the interface provided by the edge-oai-pmh module. Check the edge module's raml file to fine the correct interface to proxy.

