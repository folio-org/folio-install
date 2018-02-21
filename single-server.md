# FOLIO deployment: single server
Largely derived from Ansible playbooks at https://github.com/folio-org/folio-ansible

## Disclaimers/Caveats
* Much of this is already automated as part of the folio-ansible project
* This is not a full production install. One obvious omission is securing the Okapi API itself.

## Summary
* [Build a target Linux host](#build-a-target-linux-host)
* [Install and configure required packages](#install-and-configure-required-packages)
* [Create databases and roles](#create-databases-and-roles)
* [Install and configure Okapi](#install-and-configure-okapi)
* [Create FOLIO tenant](#create-folio-tenant)
* [Build a Stripes platform](#build-a-stripes-platform)
* [Deploy a compatible FOLIO backend, enable for tenant](#deploy-a-compatible-folio-backend-enable-for-tenant)
* [Create a FOLIO “superuser”](#create-a-folio-superuser)
* [Load permissions for “superuser”](#load-permissions-for-superuser)
* [Load module reference data](#load-module-reference-data)
* [Notes on sample data](#notes-on-sample-data)

## Build a target Linux host
1. Create an empty directory, cd into it
```
mkdir folio-install
cd folio-install
```
2. Initialize the Vagrantfile for the VM
```
vagrant init --minimal bento/ubuntu-16.04
```
3. Update the Vagrantfile to add RAM, give access to another CPU, and set up port forwarding

  * [Sample Vagrantfile](Vagrantfile)

*Note: these steps can be automated by simply cloning this repository and `cd`ing into it*

4. Bring up the Vagrant VM, log into it
```
vagrant up
vagrant ssh
```
## Install and configure required packages

### Runtime requirements: Java 8, nginx, PostgreSQL 9.6, Docker
1. Update the apt cache
```
sudo apt-get update
```
2. Install Java 8 and nginx, and make Java 8 the system default
```
sudo apt-get install openjdk-8-jdk nginx
sudo update-java-alternatives --jre-headless --jre --set java-1.8.0-openjdk-amd64
```
3. Import the PostgreSQL signing key, add the PostgreSQL apt repository, install PostgreSQL
```
wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | sudo apt-key add -
sudo add-apt-repository "deb http://apt.postgresql.org/pub/repos/apt/ xenial-pgdg main"
sudo apt-get update
sudo apt-get install postgresql-9.6 postgresql-contrib-9.6 postgresql-client-9.6 libpq-dev
```
4. Configure PostgreSQL to listen on all interfaces and allow connections from all addresses (to allow Docker connections)
  * Edit file `/etc/postgresql/9.6/main/postgresql.conf`, add line `listen_addresses = '*'` in the "Connection Settings" section
  * Edit file `/etc/postgresql/9.6/main/pg_hba.conf`, add line `host  all  all  0.0.0.0/0  md5`
  * Restart PostgreSQL with command `sudo systemctl restart postgresql`

5. Import the Docker signing key, add the Docker apt repository, install the Docker engine
```
wget --quiet -O - https://yum.dockerproject.org/gpg | sudo apt-key add -
sudo add-apt-repository "deb https://apt.dockerproject.org/repo ubuntu-xenial main"
sudo apt-get update
sudo apt-get install docker-engine
```
7. Configure Docker engine to listen on network socket
  * [Sample docker-opts.conf file](docker-opts.conf)
```
sudo mkdir -p /etc/systemd/system/docker.service.d
sudo cp /vagrant/docker-opts.conf /etc/systemd/system/docker.service.d
sudo systemctl daemon-reload
sudo systemctl restart docker
```
### Build requirements: git, curl, NodeJS, npm, Yarn, libjson-perl, libwww-perl
1. Install build requirements from Ubuntu apt repositories
```
sudo apt-get install git curl nodejs npm libjson-perl libwww-perl
```
2. Install n and mocha from npm
```
sudo npm install n -g
sudo npm install mocha -g
```
3. Import the Yarn signing key, add the Yarn apt repository, install Yarn
```
wget --quiet -O - https://dl.yarnpkg.com/debian/pubkey.gpg | sudo apt-key add -
sudo add-apt-repository "deb https://dl.yarnpkg.com/debian/ stable main"
sudo apt-get update
sudo apt-get install yarn
```
## Create databases and roles
1. Log into the PostgreSQL server as superuser
```
sudo su -c psql postgres postgres
```
2. Create a database role for Okapi and a database to persist Okapi configuration
```
CREATE ROLE okapi WITH PASSWORD 'okapi25' LOGIN CREATEDB;
CREATE DATABASE okapi WITH OWNER okapi;
```
3. Create a database role and database to persist tenant data
```
CREATE ROLE folio WITH PASSWORD 'folio123' LOGIN SUPERUSER;
CREATE DATABASE folio WITH OWNER folio;
```
4. Exit psql with `\q` command

## Install and configure Okapi
1. Import the FOLIO signing key, add the FOLIO apt repository, install okapi
```
wget --quiet -O - https://repository.folio.org/packages/debian/folio-apt-archive-key.asc | sudo apt-key add -
sudo add-apt-repository "deb https://repository.folio.org/packages/ubuntu xenial/"
sudo apt-get update
sudo apt-get install okapi
```
2. Configure Okapi to run as a single node server with persistent storage
  * Edit file `/etc/folio/okapi/okapi.conf` and make the following changes:
    * `role="dev"`
    * `port_end="9160"`
    * `host="10.0.2.15"`
    * `storage="postgres"`
    * `okapiurl="http://10.0.2.15:9130"`

3. Initialize the Okapi db
```
sudo /usr/share/folio/okapi/bin/okapi.sh --initdb
```
4. Restart Okapi
```
sudo systemctl restart okapi
```
5. Pull module descriptors from central repository (this will take awhile)
  * [Sample JSON to post to pull API](okapi-pull.json)
```
curl -w '\n' -D - -X POST -H "Content-type: application/json" -d @/vagrant/okapi-pull.json http://localhost:9130/_/proxy/pull/modules
```
## Create FOLIO tenant
1. Post the tenant initialization to Okapi
  * [Sample tenant JSON](tenant.json) 
```
curl -w '\n' -D - -X POST -H "Content-type: application/json" -d @/vagrant/tenant.json http://localhost:9130/_/proxy/tenants
```
2. Enable the Okapi internal module for the tenant
```
curl -w '\n' -D - -X POST -H "Content-type: application/json" -d '{"id":"okapi"}' http://localhost:9130/_/proxy/tenants/diku/modules
```

## Build a Stripes platform
1. Move to NodeJS LTS
```
sudo n lts
```
2. Clone the `folio-testing-platform` repository, `cd` into it
```
git clone https://github.com/folio-org/folio-testing-platform
cd folio-testing-platform
```
3. Install npm packages and build webpack
  * *Note: if you're not building on a local Vagrant box, you'll need to update the Okapi URL setting in `./stripes.config.js` first*
```
yarn install
yarn build output --sourcemap
cd ..
```
4. Configure webserver to serve Stripes webpack
  * [Sample nginx configuration](nginx-stripes.conf) 
```
sudo cp /vagrant/nginx-stripes.conf /etc/nginx/sites-available/stripes
sudo ln -s /etc/nginx/sites-available/stripes /etc/nginx/sites-enabled/stripes
sudo rm /etc/nginx/sites-enabled/default
sudo systemctl restart nginx
```

## Deploy a compatible FOLIO backend, enable for tenant
1. Build a list of frontend modules to enable
  * Each module descriptor generated by the Stripes build (except for stripes-smart-components) needs to go into a JSON array to post to the Okapi `/_/proxy/tenants/<tenantId>/install` endpoint
  * Codex connector modules (mod-codex-inventory, mod-codex-ekb) don't get pulled in by dependency, so they need to be added manually to the list
  * [Sample perl script](gen-module-list.pl) to generate JSON array from Stripes build plus Codex modules
```
perl /vagrant/gen-module-list.pl folio-testing-platform/ModuleDescriptors > enable.json
```
2. Post list of modules to Okapi, let Okapi resolve dependencies and send back a list of modules to deploy (and later enable)
```
curl -w '\n' -X POST -D - -H "Content-type: application/json" -d @enable.json -o full-install.json http://localhost:9130/_/proxy/tenants/diku/install?simulate=true
```
3. Post data source information to the Okapi environment for use by deployed modules
```
curl -w '\n' -D - -X POST -H "Content-Type: application/json" -d "{\"name\":\"db.host\",\"value\":\"10.0.2.15\"}" http://localhost:9130/_/env
curl -w '\n' -D - -X POST -H "Content-Type: application/json" -d "{\"name\":\"db.port\",\"value\":\"5432\"}" http://localhost:9130/_/env
curl -w '\n' -D - -X POST -H "Content-Type: application/json" -d "{\"name\":\"db.database\",\"value\":\"folio\"}" http://localhost:9130/_/env
curl -w '\n' -D - -X POST -H "Content-Type: application/json" -d "{\"name\":\"db.username\",\"value\":\"folio\"}" http://localhost:9130/_/env
curl -w '\n' -D - -X POST -H "Content-Type: application/json" -d "{\"name\":\"db.password\",\"value\":\"folio123\"}" http://localhost:9130/_/env
```
4. Create deployment descriptors with the versions of the modules returned from the Okapi install endpoint
  * Templates for modules are provided in the `deployment-descriptor-templates` directory of this repository.
    * Note that the `nodeId` property in the template is set to the node name for the Vagrant Okapi installation.
  * Save completed deployment descriptors in a `deployment-descriptors` directory
  * For each backend module in the JSON array generated by the Okapi `install` endpoint, update the templates with correct version information
  * [Sample perl script](gen-deploy-descrs.pl) to generate deployment descriptors
```
perl /vagrant/gen-deploy-descrs.pl --node 10.0.2.15 full-install.json /vagrant/deployment-descriptor-templates
```
 5. Pull docker images required for the build
  * Pull the image listed in each deployment descriptor, e.g.: `docker pull folioci/mod-authtoken:1.2.0-SNAPSHOT.15`
  * [Sample perl script](docker-pull.pl) to pull images
```
sudo perl /vagrant/docker-pull.pl /home/vagrant/deployment-descriptors
```
6. Deploy modules
```
cd deployment-descriptors
for i in *; do curl -w '\n' -D - -X POST -H "Content-type: application/json" -d @${i} http://localhost:9130/_/discovery/modules; done
cd ..
```
7. Enable modules for tenant
```
curl -w '\n' -X POST -D - -H "Content-type: application/json" -d @full-install.json http://localhost:9130/_/proxy/tenants/diku/install
```

## Create a FOLIO “superuser”
  * Because auth modules are enabled, need to bootstrap the superuser directly in the database
  * Need to create a record for the superuser in 3 storage modules: mod-users, mod-login, mod-permissions
  * [Sample SQL file](diku_admin.sql)
```
psql -h 10.0.2.15 -U folio -1 -f /vagrant/diku_admin.sql folio
```

## Load permissions for “superuser”
  * Modules enabled for tenant are listed at `/_/proxy/tenants/<tenantId>/modules`
  * Permissions for modules are defined in module descriptor at `/_/proxy/modules/<moduleId>`
  * Go through modules enabled for tenant, POST permissions to `/perms/users/<permissionsUserId>/permissions` endpoint
  * [Sample perl script](load-permissions.pl) to load permissions
```
perl /vagrant/load-permissions.pl
```

## Load module reference data
  * Reference data is required for mod-inventory-storage and mod-circulation-storage
    * It is included in the GitHub repos for these modules, along with a shell script for loading
  * Reference data (address types, patron groups) can be created in the UI for mod-users
  * [Sample perl script](load-reference-data.pl) to load reference data from this repository
```
perl /vagrant/load-reference-data.pl /vagrant/reference-data
```

## Notes on sample data
It can be convenient to have sample data to load into the system for testing. While that is generally outside the scope of this document, it is fairly straightforward to load sample data for inventory.

mod-inventory provides an `/inventory/ingest/mods` endpoint for loading MODS records, which it will use to create instances, holdings, and items with default values. There are sample files in the `sample-data/mod-inventory` directory of this repository.
```
# get an Okapi token
curl -w '\n' -D - -X POST -H "Content-type: application/json" -H "Accept: application/json" -H "X-Okapi-Tenant: diku" -d '{"username":"diku_admin","password":"admin"}' http://localhost:9130/authn/login
# post the files in sample-data/mod-inventory
for i in /vagrant/sample-data/mod-inventory/*.xml; do curl -w '\n' -D - -X POST -H "Content-type: multipart/form-data" -H "X-Okapi-Tenant: diku" -H "X-Okapi-Token: <okapi token>" -F upload=@${i} http://localhost:9130/inventory/ingest/mods; done
```
