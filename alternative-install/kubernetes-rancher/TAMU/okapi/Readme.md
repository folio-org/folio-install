## Environment variables

When you start the `okapi` image, you can adjust the configuration of the Okapi instance by passing one or more environment variables on the `docker run` command line. This assumes you have a Docker host named *my-folio-host.org*, a Docker network *folio-clustered* created, a database located at *pg_folio* and that multicast is enabled for your network interfaces on your Docker host.


## Linux console run command:


```docker run --rm -d --network folio-clustered --name okapi -h okapi -e OKAPI_URL=http://my-folio-host.org:9130 -e INITDB=true -e PG_HOST=pg_folio -e OKAPI_PORT=9130 -e OKAPI_NODENAME=okapi1 -e OKAPI_CLUSTERHOST=<xxx.xxx.xxx.xxx> -e OKAPI_HOST=myfolio-node-1.org -e HAZELCAST_IP=<xxx.xxx.xxx.xxx> -e HAZELCAST_VERTX_PORT=5703 -e HAZELCAST_PORT=5701 -p 9130:9130 -p 5701:5701 -p 5703:5703 -p 54327:54327/udp okapi```


## Dockerfile and variables explained below:


### INITDB

Default is *false*  - Determine whether or not to initialize the database before running okapi.

### PG_HOST

PostgreSQL host. Defaults to *localhost*

### PG_PORT

PostgreSQL port. Defaults to *5432*

### PG_USERNAME

PostgreSQL username. Defaults to *okapi*

### PG_PASSWORD

PostgreSQL password. Defaults to *okapi25*

### PG_DATABASE

PostgreSQL database. Defaults to *okapi*

### OKAPI_COMMAND

OKAPI command to use, *cluster* or *dev*. Defaults to *cluster*

### OKAPI_URL

Internal OKAPI URL to use.  Defaults to *http://localhost:9130*

### OKAPI_LOGLEVEL

OKAPI log level to use.  Defaults to *INFO*; other useful values are *DEBUG, TRACE, WARN and ERROR*

### OKAPI_HOST

OKAPI host to use for deployment service.  Defaults to *localhost*

### OKAPI_NODENAME

Name of the OKAPI Cluster node of this instance.

### OKAPI_CLUSTERHOST

The Docker host machine interface address for the OKAPI Cluster node to use (typically an IP). Defaults to *hostname IP*

### OKAPI_PORT

The port on which Okapi listens. Defaults to *9130*

### HAZELCAST_FILE

The configuration file for hazelcast OKAPI Cluster to use for cluster node discovery. Defaults to */usr/local/bin/folio/okapi/hazelcast.xml*

### HAZELCAST_IP

The PUBLIC IP for hazelcast of the OKAPI Cluster node to use. Defaults to *localhost IP*

### HAZELCAST_PORT

The PUBLIC network interface port for hazelcast in the OKAPI Cluster node to use. Defaults to *5701*

### HAZELCAST_VERTX_PORT

The TCP port for vertx cluster communications to use.
