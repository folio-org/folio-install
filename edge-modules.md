# Installing Edge Modules
Begin by collecting information about the edge module you are installing. In this example, we'll install edge-oai-pmh. Collect information on your own environment following the example below:
| Variable | Example Value | Notes|
|----------|-------|------|
| Institutional User | institution_user | username of your choosing |
| Instituitonal User Password | institutional_pass | password of your choosing
| Tenant | diku | 
| Permission sets | oai-pmh.all | permissions to be assigned to institutional user |

## Create institutional user
An institutional must be created with appropriate permissions to use the edge module. You can use the included `create-user.py` script to create a user and assign permissions if you choose.
```
./create-user -u institutional_user -p institutional_pass \
    --permissions edge-oai-pmh.all --admin-user diku_admin \
    --admin-password admin 
```
If you need to assign more than one permission set, use a comma delimeted list, i.e. `--permissions edge-rtac.all,edge-oai-pmh.all`.

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
diku=institutional_user,institutional_pass
```
### Set up a docker compose file
Set up a docker compose file in `/etc/folio/edge/docker-compose.yml` that defines each edge module you want to run as a service. For example, we'll define a service for edge-oai-pmh here.
```
version: '2'
services:
  edge-oai-pmh:
    ports: 
      - "9701:8081"
    image: folioci/edge-oai-pmh:2.1.0-SNAPSHOT.24
    volumes: 
      - /etc/folio/edge:/mnt
    command: 
      -"-Dokapi_url=http://localhost:9130"
      -"-Dsecure_store_props=/mnt/edge-oai-pmh-ephemeral.properties"
    restart: "always"
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
Configure your Nginx to proxy your edge modules. In this example, we'll configure edge-rtac.
```
server {
  listen 8000;
  server_name localhost;
  charset utf-8;
  
  location /prod/rtac {
      proxy_pass http://localhost:9700;
  }
}
```
In this configuration, nginx is listening on port 8000 which is an arbitrary unused port selected to listen for requests to edge APIs. The location `/prod/rtac` is based on the interface provided by the edge-rtac module. Check the edge module's raml file to fine the correct interface to proxy.

