## Environment variables

When you start the `okapi` image, you can adjust the configuration of the Okapi instance by passing one or more environment variables on the `docker run` command line. This assumes you have a Docker network `folio-clustered` created, and that multicast is enabled for your network interfaces on your Docker host.


### Linux console run command ###


`docker run --rm -d --network folio-clustered --name okapi -h okapi -e OKAPI_URL=http://okapi:9130 -e INITDB=true -e PG_HOST=pg-folio -e OKAPI_PORT=9130 -e OKAPI_NODENAME=okapi1 -e OKAPI_CLUSTERHOST=localhost -e OKAPI_HOST=localhost -e HAZELCAST_IP=localhost -e HAZELCAST_VERTX_PORT=5702 -e HAZELCAST_PORT=5701 -p 9130:9130 -p 5701:5701 -p 5702:5702 -p 54327:54327/udp okapi`


### Dockerfile and variables explained below ###


### INITDB

Determine whether or not to initialize the database before running Okapi. Default `false`.

### PG_HOST

PostgreSQL host. Default `pg-folio`.

### PG_PORT

PostgreSQL port. Default `5432`.

### PG_USERNAME

PostgreSQL username. Default `okapi`.

### PG_PASSWORD

PostgreSQL password. Default `okapi25`.

### PG_DATABASE

PostgreSQL database. Default `okapi`.

### OKAPI_COMMAND

OKAPI command to use, `cluster`, `dev`, `deployment`, `proxy`, or `help`. Default `dev`.

### OKAPI_URL

Internal OKAPI URL to use. Default `http://localhost:9130`.

### OKAPI_LOGLEVEL

OKAPI log level to use, `INFO`, `DEBUG`, `TRACE`, `WARN` and `ERROR`. Default `INFO`.

### OKAPI_HOST

OKAPI host to use for deployment service.  Default `localhost`.

### OKAPI_NODENAME

Name of the OKAPI Cluster node of this instance. Default `okapi1`.

### OKAPI_CLUSTERHOST

The Docker host machine interface address for the OKAPI Cluster node to use (typically an IP). Defaults to the hostname IP.

### OKAPI_PORT

The port on which Okapi listens. Default `9130`.

### OKAPI_STORAGE

Defines the storage back end, `postgres`, `mongo` or `inmemory`. Default `inmemory`.

### HAZELCAST_FILE

The configuration file for hazelcast OKAPI Cluster to use for cluster node discovery. Default `/usr/local/bin/folio/okapi/hazelcast.xml`.

### HAZELCAST_IP

The PUBLIC IP for hazelcast of the OKAPI Cluster node to use. Default `localhost` IP.

### HAZELCAST_PORT

The PUBLIC port for hazelcast in the OKAPI Cluster node to use. Default `5701`.

### HAZELCAST_VERTX_PORT

The TCP port for vertx cluster communications to use. Default `5702`.
