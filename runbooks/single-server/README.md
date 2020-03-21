# FOLIO deployment: single server

** NOTE: 20200320: ** This document is still being adjusted for q1-2020 release.
See [FOLIO-2507](https://issues.folio.org/browse/FOLIO-2507).

This procedure will establish a FOLIO system based on the "Q1-2020 FameFlower" quarterly release.

Largely derived from Ansible playbooks at https://github.com/folio-org/folio-ansible

## Disclaimers/Caveats

* Much of this is already automated as part of the folio-ansible project.
* This is not considered to be a full production install.
* There are some steps in the procedure called "sidebar" where one can go beyond the quarterly release to build a snapshot-based system (be careful).
* This release uses PostgreSQL 10 version.
* The _minimum_ RAM required for a system based on [platform-core](https://github.com/folio-org/platform-core) is 10 GB. See [why](#frequently-asked-questions). Keep this in mind if you are running on a VM.
* To instead build a system based on [platform-complete](https://github.com/folio-org/platform-complete) will require approximately 20 GB.

## Summary

<!-- ../../../okapi/doc/md2toc -l 2 -h 2 -s 2 README.md -->
* [Build a target Linux host](#build-a-target-linux-host)
* [Install and configure required packages](#install-and-configure-required-packages)
* [Create databases and roles](#create-databases-and-roles)
* [Install and configure Okapi](#install-and-configure-okapi)
* [Create FOLIO tenant](#create-folio-tenant)
* [Build the latest release of the FOLIO Stripes platform](#build-the-latest-release-of-the-folio-stripes-platform)
* [Configure webserver to serve Stripes webpack](#configure-webserver-to-serve-stripes-webpack)
* [Deploy a compatible FOLIO backend, enable for tenant](#deploy-a-compatible-folio-backend-enable-for-tenant)
* [Create a FOLIO “superuser” and load permissions](#create-a-folio-superuser-and-load-permissions)
* [Load module reference data](#load-module-reference-data)
* [Load sample data](#load-sample-data)
* [Install and serve edge modules for platform-complete](#install-and-serve-edge-modules-for-platform-complete)
* [Secure the Okapi API (supertenant)](#secure-the-okapi-api-supertenant)
* [Known issues](#known-issues)
* [Frequently asked questions](#frequently-asked-questions)

## Build a target Linux host

1. Clone this repository, cd into the directory that is created

```
git clone https://github.com/folio-org/folio-install
cd folio-install
git checkout folio-2507-q1-2020-single-server
cd runbooks/single-server
```

The default procedure will create a VirtualBox VM based on this [Vagrantfile](Vagrantfile), running a generic Ubuntu Xenial OS, with 10 GB RAM and 2 CPUs. Port 9130 of the guest will be forwarded to port 9130 of the host, and port 80 of the guest will be forwarded to port 3000 of the host. The `folio-install/runbooks/single-server` directory on the host will be shared on the guest at the `/vagrant` mount point.

2. Decide between platform-core and platform-complete

The default procedure uses the
[platform-core](https://github.com/folio-org/platform-core) configuration
and this [Vagrantfile](Vagrantfile).

To instead build a system based on [platform-complete](https://github.com/folio-org/platform-complete),
copy [Vagrantfile-complete](Vagrantfile-complete) to `Vagrantfile`.
This sets the `vb.memory` to be 20 GB and forwards the additional port 8130 for serving edge modules.
Also copy [scripts/nginx-stripes-complete.conf](scripts/nginx-stripes-complete.conf) to `scripts/nginx-stripes.conf` file.
Throughout these instructions, replace every mention of `platform-core` with `platform-complete`.

3. Bring up the Vagrant VM, log into it

```
vagrant up
vagrant ssh
```

## Install and configure required packages

### Runtime requirements: Java 8, nginx, PostgreSQL 10, Docker

1. Update the apt cache

```
sudo apt-get update
```

2. Install Java 8 and nginx, and make Java 8 the system default

```
sudo apt-get -y install openjdk-8-jdk nginx
sudo update-java-alternatives --jre-headless --jre --set java-1.8.0-openjdk-amd64
```

3. Import the PostgreSQL signing key, add the PostgreSQL apt repository, install PostgreSQL

```
wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | sudo apt-key add -
sudo add-apt-repository "deb http://apt.postgresql.org/pub/repos/apt/ xenial-pgdg main"
sudo apt-get update
sudo apt-get -y install postgresql-10 postgresql-client-10 postgresql-contrib-10 libpq-dev
```

4. Configure PostgreSQL to listen on all interfaces and allow connections from all addresses (to allow Docker connections)

  * Edit file `/etc/postgresql/10/main/postgresql.conf` to add line `listen_addresses = '*'` in the "Connection Settings" section
  * Edit file `/etc/postgresql/10/main/pg_hba.conf` to add line `host  all  all  0.0.0.0/0  md5`
  * Restart PostgreSQL with command `sudo systemctl restart postgresql`

5. Import the Docker signing key, add the Docker apt repository, install the Docker engine

```
sudo apt-get -y install apt-transport-https ca-certificates gnupg-agent software-properties-common
wget --quiet -O - https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
sudo add-apt-repository "deb https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
sudo apt-get update
sudo apt-get -y install docker-ce docker-ce-cli containerd.io
```

6. Configure Docker engine to listen on network socket

  * [Sample docker-opts.conf file](scripts/docker-opts.conf)

```
sudo mkdir -p /etc/systemd/system/docker.service.d
sudo cp /vagrant/scripts/docker-opts.conf /etc/systemd/system/docker.service.d
sudo systemctl daemon-reload
sudo systemctl restart docker
```

### Build requirements: git, curl, NodeJS, npm, Yarn, libjson-perl, libwww-perl libuuid-tiny-perl

1. Install build requirements from Ubuntu apt repositories

```
sudo apt-get -y install git curl nodejs npm libjson-perl libwww-perl libuuid-tiny-perl
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
sudo apt-get -y install yarn
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

1. Import the FOLIO signing key, add the FOLIO apt repository, install okapi (of this release)

```
wget --quiet -O - https://repository.folio.org/packages/debian/folio-apt-archive-key.asc | sudo apt-key add -
sudo add-apt-repository "deb https://repository.folio.org/packages/ubuntu xenial/"
sudo apt-get update
sudo apt-get -y install okapi=2.35.1-1
sudo apt-mark hold okapi
```

### Sidebar: Okapi releases

If you would like to work with the latest Okapi release, remove the hold command above and change the install command above to:

```
sudo apt-get -y install okapi
```

Note that there is some risk in this, as the latest Okapi release may not have been tested with the rest of the components in the quarterly release.

### Mainbar: Continue configure Okapi

2. Configure Okapi to run as a single node server with persistent storage

  * Edit file `/etc/folio/okapi/okapi.conf` and make the following changes:
    * `role="dev"`
    * `port_end="9230"`
    * `host="10.0.2.15"`
    * `storage="postgres"`
    * `okapiurl="http://10.0.2.15:9130"`

3. Restart Okapi

```
sudo systemctl daemon-reload
sudo systemctl restart okapi
```

The Okapi log is at `/var/log/folio/okapi/okapi.log`

4. Pull module descriptors from central registry:

  * [Sample JSON to post to pull API](scripts/okapi-pull.json)

```
curl -w '\n' -D - -X POST -H "Content-type: application/json" \
  -d @/vagrant/scripts/okapi-pull.json \
  http://localhost:9130/_/proxy/pull/modules
```

## Create FOLIO tenant

1. Post the tenant initialization to Okapi

  * [Sample tenant JSON](scripts/tenant.json)

```
curl -w '\n' -D - -X POST -H "Content-type: application/json" \
  -d @/vagrant/scripts/tenant.json \
  http://localhost:9130/_/proxy/tenants
```

2. Enable the Okapi internal module for the tenant

```
curl -w '\n' -D - -X POST -H "Content-type: application/json" \
  -d '{"id":"okapi"}' \
  http://localhost:9130/_/proxy/tenants/diku/modules
```

## Build the latest release of the FOLIO Stripes platform

1. Move to NodeJS LTS

```
sudo n lts
```

2. Clone the `platform-core` repository, `cd` into it

```
git clone https://github.com/folio-org/platform-core
cd platform-core
```

3. Check out the `q1-2020` branch. The HEAD of this branch should reflect the latest release, including any bug fix releases.

```
git checkout q1-2020
```

4. Install npm packages

```
yarn install
```

### Sidebar: Building from the bleeding edge

This section goes beyond the quarterly release. Be careful.

The `platform-core` platform is constructed with versions of FOLIO components and dependencies that have been tested together and are known to work.

If you would rather build Stripes with the most recent code that may not have been fully integration tested, clone the `platform-core` repository at step 2 above, omit the step of checking out the latest tag, and do this instead:

```
git checkout snapshot
yarn install
```

**Be warned, this could result in a bundle with unstable code!**

If you build Stripes this way, then the FOLIO backend system needs to be constructed a little differently.
See [Sidebar: building from the bleeding edge -- part II](#sidebar-building-from-the-bleeding-edge----part-ii) below
(but before proceeding to that next sidebar, continue with these mainbar instructions to build the webpack and to configure the Stripes nginx server).

Now we have today's snapshot set of dependencies installed, instead of the release.
That is the end of this part of the sidebar divergence, so now continue with the shared mainbar procedure.

### Mainbar: Continue build Stripes

5. Configure Stripes

The platform's `stripes.config.js` provides the default okapi url and tenant and branding. Edit to suit.

6. Build webpack

*Note: if you're not building on a local Vagrant box, see [Options for `yarn build`](#sidebar-options-for-yarn-build) below*

```
NODE_ENV=production yarn build output
cd ..
```

### Sidebar: Options for `yarn build`

The `yarn build` command above can be changed to build the webpack in different ways. For more details, see the documentation for the [Stripes command line](https://github.com/folio-org/stripes-cli/blob/master/doc/commands.md#build-command).

## Configure webserver to serve Stripes webpack

Now that the webpack is built, proceed to configure the 'nginx' server.
Remember if building for `platform-complete` then set that in the `/vagrant/scripts/nginx-stripes.conf` file.

  * [Sample nginx configuration](scripts/nginx-stripes.conf)

```
sudo cp /vagrant/scripts/nginx-stripes.conf /etc/nginx/sites-available/stripes
sudo ln -s /etc/nginx/sites-available/stripes /etc/nginx/sites-enabled/stripes
sudo rm /etc/nginx/sites-enabled/default
sudo systemctl restart nginx
```

## Deploy a compatible FOLIO backend, enable for tenant

The tagged release of `platform-core` contains an `okapi-install.json` file which, when posted to Okapi, will download all the necessary backend modules as Docker containers, deploy them to the local system, and enable them for your tenant. There is also a `stripes-install.json` file that will enable the frontend modules for the tenant and load the necessary permissions.

(If you are trying the bleeding-edge snapshot, then skip ahead to the next sidebar.)

1. Post data source information to the Okapi environment for use by deployed modules

```
curl -w '\n' -D - -X POST -H "Content-Type: application/json" -d "{\"name\":\"DB_HOST\",\"value\":\"10.0.2.15\"}" http://localhost:9130/_/env
curl -w '\n' -D - -X POST -H "Content-Type: application/json" -d "{\"name\":\"DB_PORT\",\"value\":\"5432\"}" http://localhost:9130/_/env
curl -w '\n' -D - -X POST -H "Content-Type: application/json" -d "{\"name\":\"DB_DATABASE\",\"value\":\"folio\"}" http://localhost:9130/_/env
curl -w '\n' -D - -X POST -H "Content-Type: application/json" -d "{\"name\":\"DB_USERNAME\",\"value\":\"folio\"}" http://localhost:9130/_/env
curl -w '\n' -D - -X POST -H "Content-Type: application/json" -d "{\"name\":\"DB_PASSWORD\",\"value\":\"folio123\"}" http://localhost:9130/_/env
```

2. Post the list of backend modules to deploy and enable. Also set the [tenantParameters](https://github.com/folio-org/okapi/blob/master/doc/guide.md#install-modules-per-tenant) to load their sample and reference data:

```
curl -w '\n' -D - -X POST -H "Content-type: application/json" \
  -d @platform-core/okapi-install.json \
  http://localhost:9130/_/proxy/tenants/diku/install?deploy=true\&preRelease=false\&tenantParameters=loadSample%3Dtrue%2CloadReference%3Dtrue
```

Note: This will take a long time to return, as all the Docker images must be pulled from Docker Hub.
Progress can be followed in the Okapi log at `/var/log/folio/okapi/okapi.log` and via `sudo docker ps | grep -v "^CONTAINER" | wc -l`

3. Post the list of Stripes modules to enable

```
curl -w '\n' -D - -X POST -H "Content-type: application/json" \
  -d @platform-core/stripes-install.json \
  http://localhost:9130/_/proxy/tenants/diku/install?preRelease=false
```

### Sidebar: Building from the bleeding edge -- part II

This section goes beyond the quarterly release. Be careful.

If you would rather deploy the most recent code for the backend, rather than relying on the `okapi-install.json` and `stripes-install.json` files from the release branch, then create your own files using the procedure below instead of the above section. **Proceed at your own risk!** You could end up with a system that contains unstable code.

1. Build a list of frontend modules to enable

```
cd platform-core
yarn build-module-descriptors
cd ..
```

  * Each module descriptor ID generated by the yarn command above (except for a specific few) needs to go into a JSON array to post to the Okapi `/_/proxy/tenants/<tenantId>/install` endpoint
  * Some modules do not get pulled in by dependency, so they need to be added to the list
    (i.e. those that are noted in the release branch `install-extras.json` file)
  * Some FOLIO packages generate module descriptors that aren't in the central registry, so they need to be removed from the list
  * [Sample perl script](scripts/gen-module-list.pl) to generate JSON array from Stripes build with the correct packages added and removed:

When building the default system based on `platform-core` then do:

```
perl /vagrant/scripts/gen-module-list.pl \
  --extra-modules mod-codex-inventory \
  platform-core/ModuleDescriptors > stripes-install.json
```

If instead building a system based on `platform-complete` then do:

```
perl /vagrant/scripts/gen-module-list.pl \
  --extra-modules mod-audit,mod-audit-filter,mod-codex-inventory,mod-codex-ekb,mod-data-import-converter-storage,mod-erm-usage-harvester,mod-user-import,mod-gobi,mod-oai-pmh,mod-patron,mod-rtac,edge-oai-pmh,edge-orders,edge-patron,edge-rtac \
  --exclude-modules stripes-erm-components \
  platform-complete/ModuleDescriptors > stripes-install.json
```

2. Post list of modules to Okapi, let Okapi resolve dependencies and send back a list of modules to deploy and enable

```
curl -w '\n' -X POST -D - -H "Content-type: application/json" \
  -d @stripes-install.json -o full-install.json \
  http://localhost:9130/_/proxy/tenants/diku/install?simulate=true
```

3. Extract the backend modules from the `full-install.json` file

  * Backend modules will be deployed by Okapi, so the list needs to be posted separated (frontend modules are not deployed, only enabled for the tenant)
  * Conventionally, backend module names begin with `mod-`, while frontend modules begin with `folio_`
  * [Sample perl script](scripts/build-okapi-install.pl) to extract the backend modules

```
perl /vagrant/scripts/build-okapi-install.pl full-install.json > okapi-install.json
```

4. Post data source information to the Okapi environment for use by deployed modules

```
curl -w '\n' -D - -X POST -H "Content-Type: application/json" -d "{\"name\":\"DB_HOST\",\"value\":\"10.0.2.15\"}" http://localhost:9130/_/env
curl -w '\n' -D - -X POST -H "Content-Type: application/json" -d "{\"name\":\"DB_PORT\",\"value\":\"5432\"}" http://localhost:9130/_/env
curl -w '\n' -D - -X POST -H "Content-Type: application/json" -d "{\"name\":\"DB_DATABASE\",\"value\":\"folio\"}" http://localhost:9130/_/env
curl -w '\n' -D - -X POST -H "Content-Type: application/json" -d "{\"name\":\"DB_USERNAME\",\"value\":\"folio\"}" http://localhost:9130/_/env
curl -w '\n' -D - -X POST -H "Content-Type: application/json" -d "{\"name\":\"DB_PASSWORD\",\"value\":\"folio123\"}" http://localhost:9130/_/env
```

5. Post the list of backend modules to deploy and enable (as noted above, it will take a long time)

```
curl -w '\n' -D - -X POST -H "Content-type: application/json" \
  -d @okapi-install.json \
  http://localhost:9130/_/proxy/tenants/diku/install?deploy=true\&tenantParameters=loadSample%3Dtrue%2CloadReference%3Dtrue
```

6. Post the list of Stripes modules to enable

```
curl -w '\n' -D - -X POST -H "Content-type: application/json" \
  -d @stripes-install.json \
  http://localhost:9130/_/proxy/tenants/diku/install
```

That is the end of the sidebar divergence, so now continue with the shared mainbar procedure.

## Create a FOLIO “superuser” and load permissions

See the [Securing Okapi](https://github.com/folio-org/okapi/blob/master/doc/guide.md#securing-okapi) section of the Guide and the linked detail.

  * A superuser can only be created if the `authtoken` interface is disabled for the tenant
  * Need to create a record for the superuser in 3 storage modules (mod-users, mod-login, mod-permissions)
    and the service-points in mod-inventory-storage.
  * After creating the superuser, reenable the `authtoken` interface
  * All permissionSets that are not included in other permissionSets can be listed with the CQL query `/perms/permissions?query=childOf%3D%3D%5B%5D&length=500` (`childOf==[]`)
  * Go through permissionSets, POST permissions to `/perms/users/<permissionsUserId>/permissions` endpoint
  * [Sample perl script](scripts/bootstrap-superuser.pl) to create a superuser and load permissions

```
perl /vagrant/scripts/bootstrap-superuser.pl \
  --tenant diku --user diku_admin --password admin \
  --okapi http://localhost:9130
```

## Load module reference data

Reference data for various backend modules is already automatically loaded
at the [enable for tenant](#deploy-a-compatible-folio-backend-enable-for-tenant) step above.

If other reference data is needed, then the [sample perl script](scripts/load-data.pl) can load reference data too.

## Load sample data

Sample data for various backend modules is already automatically loaded
at the [enable for tenant](#deploy-a-compatible-folio-backend-enable-for-tenant) step above.

All necessary `platform-core` and `platform-complete` modules are now using that mechanism.

If additional JSON sample data is needed, then use the [sample perl script](scripts/load-data.pl)
to load data from sub-directories of the `sample-data` directory, as explained in the script.

### Load MODS records

The mod-inventory provides an `/inventory/ingest/mods` endpoint for loading MODS records, which it will use to create instances, holdings, and items with default values. There are sample files in the `sample-data/mod-inventory` directory of this repository.

First login and obtain an Okapi token -- it will be in the x-okapi-token header

```
curl -w '\n' -D - -X POST -H "Content-type: application/json" \
  -H "Accept: application/json" -H "X-Okapi-Tenant: diku" \
  -d '{"username":"diku_admin","password":"admin"}' \
  http://localhost:9130/authn/login
```

Then post the files from the `sample-data/mod-inventory` directory.
Replace the `<okapi token>` placeholder with the actual token from the previous response.

```
for i in /vagrant/sample-data/mod-inventory/*.xml; do curl -w '\n' -D - -X POST -H "Content-type: multipart/form-data" -H "X-Okapi-Tenant: diku" -H "X-Okapi-Token: <okapi token>" -F upload=@${i} http://localhost:9130/inventory/ingest/mods; done
```
## Install and serve edge modules for platform-complete

This section is only relevant for platform-complete.

You may choose to also install and serve edge APIs.

1. Gather information

    Begin by collecting information about the edge module that you are installing. In this example, we'll install edge-oai-pmh. Collect information on your own environment following the example below:

    | Variable | Example Value | Notes |
    | -------- | ----- | ---- |
    | Institutional User | instuser | username of your choosing |
    | Institutional User Password | instpass | password of your choosing |
    | Tenant | diku | |
    | Permission sets | oai-pmh.all | permissions to be assigned to institutional user |

2. Create institutional user

    An institutional user must be created with appropriate permissions to use the edge module. You can use the included `scripts/create-user.py` to create a user and assign permissions.
    ```
    python3 scripts/create-user.py -u instuser -p instpass \
        --permissions oai-pmh.all --tenant diku \
        --admin-user diku_admin --admin-password admin
    ```
    If you need to specify an Okapi instance running somewhere other than `http://localhost:9130` then add the `--okapi-url` flag to pass a different url.
    If more than one permission set needs to be assigned, then use a comma delimited list, i.e. `--permissions edge-rtac.all,edge-oai-pmh.all`

3. Add a secure store for access credentials

    Provide edge module access credentials for tenants and their institutional user.

    Refer to the documentation in the [edge-common](https://github.com/folio-org/edge-common) repository for details about the various secure store facilities.
    For this example, we will use a basic EphemeralStore using an `ephemeral.properties` file which stores credentials in plain text.
    This is meant for development and demonstration purposes only.

    ```
    vagrant ssh
    sudo mkdir -p /etc/folio/edge
    sudo vi /etc/folio/edge/edge-oai-pmh-ephemeral.properties
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

4. Start edge module Docker containers

    The containers for edge modules can be established in various of ways. This guide uses docker-compose.
    If docker-compose is not already installed or needs to be upgraded, then follow the instructions from [docker](https://docs.docker.com/compose/install/). For example:
    ```
    sudo curl -L "https://github.com/docker/compose/releases/download/1.24.0/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
    sudo chmod +x /usr/local/bin/docker-compose
    ```

    Set up a docker compose file in `/etc/folio/edge/docker-compose.yml` that defines each edge module that is to be run as a service.

    Find the relevant module versions:
    ```
    curl -s http://localhost:9130/_/proxy/tenants/diku/modules | jq '.[].id' | grep edge
    ```

    For example, we will define a service only for [edge-oai-pmh](https://github.com/folio-org/edge-oai-pmh) here.

    ```
    version: '2'
    services:
      edge-oai-pmh:
        ports:
          - "9700:8081"
        image: folioorg/edge-oai-pmh:2.0.0
        volumes:
          - /etc/folio/edge:/mnt
        command:
          -"Dokapi_url=http://10.0.2.15:9130"
          -"Dsecure_store_props=/mnt/edge-oai-pmh-ephemeral.properties"
        restart: "always"
    ```
    In this configuration, use the IP address or DNS record for Okapi (not 'localhost') for the okapi_url option.

    Now start the edge module containers:
    ```
    cd /etc/folio/edge
    sudo docker-compose up -d
    ```
5. Set up NGINX

    The nginx is already installed during previous sections.

    Create a new virtual host configuration to proxy the edge modules.
    ```
    sudo vi /etc/nginx/sites-available/edge
    ```
    In this example, we will only configure edge-oai-pmh:
    ```
    server {
      listen 8130;
      server_name localhost;
      charset utf-8;

      location /oai {
        proxy_pass http://localhost:9700;
      }
    }
    ```
    Now link that new configuration and restart nginx.
    ```
    sudo ln -s /etc/nginx/sites-available/edge /etc/nginx/sites-enabled/edge
    sudo service nginx restart
    ```
    In this configuration, nginx is listening on port 8130 which is an arbitrary unused port selected to listen for requests to edge APIs.
    The location `/oai` is based on the interface provided by the edge-oai-pmh module.
    Check the edge module's [API reference documentation](https://dev.folio.org/reference/api/#edge-oai-pmh) to find the relevant endpoint to proxy.

6. Create an Edge API key

    Refer to the documentation in the [edge-common](https://github.com/folio-org/edge-common) repository for more details on how to create an API key for a production-ready system.

    On a host system, follow this procedure to generate the API key for the tenant and institutional user that were configured in the previous sections:

    ```
    cd ~
    git clone https://github.com/folio-org/edge-common.git
    cd edge-common
    mvn package
    java -jar target/edge-common-api-key-utils.jar -g -t diku -u instuser
    ```
    This will return an API key that must be included in requests to edge modules. In this example, we get `eyJzIjoiRnRUNEdQYXlZWiIsInQiOiJkaWt1IiwidSI6Imluc3R1c2VyIn0=`

7. Test the edge module access

    Verify a valid response by constructing a request according to the relevant module's documentation.
    For [mod-oai-pmh](https://github.com/folio-org/mod-oai-pmh) for example:
    ```
    curl -s "http://localhost:8130/oai?apikey=eyJzIjoiRnRUNEdQYXlZWiIsInQiOiJkaWt1IiwidSI6Imluc3R1c2VyIn0=&verb=Identify" | xq '.'
    ```

## Secure the Okapi API (supertenant)

If this is a production install, you may want to secure the Okapi API. You can secure the Okapi API or supertenant either by using the included sample script [scripts/secure-supertenant.py](scripts/secure-supertenant.py) or by following the instructions in the [Securing Okapi](https://github.com/folio-org/okapi/blob/master/doc/securing.md) guide.

The included script requires mod-authtoken, mod-login, mod-permissions, and mod-users. It will enable those modules on the supertenant, create a superuser, and grant the `okapi.all` permission set to the superuser. It will also grant all permissions to the superuser on the modules that it enables.

**CAUTION**: When the supertenant is secured, you must login using mod-authtoken to obtain an authtoken and include it in the `x-okapi-token` header for every request to the Okapi API. For example, if you want to repeat any of the calls to Okapi in this guide, you will need to include `x-okapi-token:YOURTOKEN` and `x-okapi-tenant:supertenant` as headers for any requests to the Okapi API.

To use the included script, run the following command replacing USERNAME and PASSWORD with your desired values:
```
python3 /vagrant/scripts/secure-supertenant.py -u USERNAME -p PASSWORD
```

You can also specify a different url for Okapi by using the `-o` option. The default value is `http://localhost:9130` if you do not specify this option.

## Known issues

This Jira filter shows known critical issues that are not yet resolved:
* [Known critical Q4-2019 issues](https://issues.folio.org/issues/?filter=11914)

## Frequently asked questions

### Why so much memory required

Why is a lot of vagrant memory allocated?

For the platform-core there are about 25 backend modules (about 45 for platform-complete),
with their docker images sizes being about 160 MB each (as an average).
Some room is needed for loading the data and running the database.

More is needed during the preparation phase, while building the Stripes webpack.
If short on memory, then build this elsewhere.

### Adjust LaunchDescriptor properties

Each back-end module has a default LaunchDescriptor in its ModuleDescriptor.
These have basic minimal memory settings that are appropriate for the FOLIO hosted reference environments.
For a real system, these would need to be [over-ridden](https://dev.folio.org/guides/module-descriptor/#launchdescriptor-properties).

