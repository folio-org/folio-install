## Environment variables

When you start the `okapi` image, you can adjust the configuration of the Okapi instance by passing one or more environment variables on the `docker run` command line. This assumes you have a Docker network 'folio-clustered' created, and that multicast is enabled for your network interfaces on your Docker host.


### Linux console run command ###


`docker run --rm -d --network folio-clustered --name okapi -h okapi -e OKAPI_URL=http://okapi:9130 -e INITDB=true -e PG_HOST=pg-folio -e OKAPI_PORT=9130 -e OKAPI_NODENAME=okapi1 -e OKAPI_CLUSTERHOST=localhost -e OKAPI_HOST=localhost -e HAZELCAST_IP=localhost -e HAZELCAST_VERTX_PORT=5703 -e HAZELCAST_PORT=5701 -p 9130:9130 -p 5701:5701 -p 5703:5703 -p 54327:54327/udp okapi`


### Dockerfile and variables explained below ###


### INITDB

Default is false.  Determine whether or not to initialize the database before running okapi

### PG_HOST

PostgreSQL host. Defaults to pg-folio.

### PG_PORT

PostgreSQL port. Defaults to 5432.

### PG_USERNAME

PostgreSQL username. Defaults to okapi.

### PG_PASSWORD

PostgreSQL password. Defaults to okapi25.

### PG_DATABASE

PostgreSQL database. Defaults to okapi.

### OkAPI_COMMAND

OKAPI command to use, cluster or dev. Defaults to dev.

### OKAPI_URL

Internal OKAPI URL to use. Defaults to http://localhost:9130.

### OKAPI_LOGLEVEL

OKAPI log level to use. Defaults to INFO; other useful values are DEBUG, TRACE, WARN and ERROR.

### OKAPI_HOST

OKAPI host to use for deployment service.  Default localhost.

### OKAPI_NODENAME

Name of the OKAPI Cluster node of this instance.

### OKAPI_CLUSTERHOST

The Docker host machine interface address for the OKAPI Cluster node to use (typically an IP). Default hostname IP.

### OKAPI_PORT

The port on which Okapi listens. Defaults to 9130.

### HAZELCAST_FILE

The configuration file for hazelcast OKAPI Cluster to use for cluster node discovery. Default /usr/local/bin/folio/okapi/hazelcast.xml.

### HAZELCAST_IP

The PUBLIC IP for hazelcast of the OKAPI Cluster node to use. Default localhost IP.

### HAZELCAST_PORT

The PUBLIC port for hazelcast in the OKAPI Cluster node to use. Default 5701.

### HAZELCAST_VERTX_PORT

The TCP port for vertx cluster communications to use.