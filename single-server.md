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
* [Deploy a compatible FOLIO backend](#deploy-a-compatible-FOLIO-backend)
* [Enable modules for tenant](#enable-modules-for-tenant)
* [Create a FOLIO “superuser”](#create-a-folio-superuser)
* [Load permissions for “superuser”](#load-permissions-for-superuser)
* [Load module reference data](#load-module-reference-data)

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
3. Update the Vagrantfile to add RAM and give access to another CPU

  * [Sample Vagrantfile](Vagrantfile)

4. Bring up the Vagrant VM, log into it
```
vagrant up
vagrant ssh
```
## Install and configure required packages

### Runtime requirements: Java 8, PostgreSQL 9.6, Docker
1. Update the apt cache
```
sudo apt-get update
```
2. Install Java 8 and make it the system default
```
sudo apt-get install openjdk-8-jdk
sudo update-java-alternatives --jre-headless --jre --set java-1.8.0-openjdk-amd64java-1.8.0-openjdk-amd64
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
### Build requirements: git, curl, NodeJS, npm, Yarn
1. Install build requirements from Ubuntu apt repositories
```
sudo apt-get install git curl nodejs npm
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
* [Sample tenant JSON](tenant.json) 
```
curl -w '\n' -D - -X POST -H "Content-type: application/json" -d @/vagrant/tenant.json http://localhost:9130/_/proxy/tenants
```

## Build a Stripes platform
## Deploy a compatible FOLIO backend
## Enable modules for tenant
## Create a FOLIO “superuser”
## Load permissions for “superuser”
## Load module reference data
