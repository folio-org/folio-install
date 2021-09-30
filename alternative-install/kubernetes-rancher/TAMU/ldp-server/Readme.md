## Build Docker image

`docker build -t ldp-server .`


### Linux console run command ###

`docker run --rm -d --network folio-clustered --name ldp-server -h ldp-server -e DATADIR=/var/lib/ldp ldp-server`


### Setting the LDP container command ###

There are two steps that need to take place for LDP to properly run:
1) Init the LDP database: ```init-database -D /var/lib/ldp --profile folio```
2) Start the LDP server: ```server -D /var/lib/ldp --trace```

You can also force a data update with the command ```update -D /var/lib/ldp --trace```


## Environment variables

When you start the `ldp-server` image, you can adjust the configuration of the ldp instance by passing one or more environment variables on the `docker run` command line. This assumes you have a Docker network `folio-clustered` created.

### DATADIR

Data directory used inside the container. Defaults to `/var/lib/ldp`.