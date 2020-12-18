## Environment variables

When you start the `mod-ldp` image, you can adjust the configuration of the ldp instance by passing one or more environment variables on the `docker run` command line. This assumes you have a Docker network `folio-clustered` created.


### Linux console run command ###

`docker run --rm -d --network folio-clustered --name mod-ldp -h mod-ldp -e DATADIR=/var/lib/ldp mod-ldp`


### Setting the LDP container command ###

There are two steps that need to take place for LDP to properly run:
1) Init the LDP database: ```init-database -D /var/lib/ldp --profile folio```
2) Start the LDP server: ```server -D /var/lib/ldp --trace```


### Dockerfile and variables explained below ###


### DATADIR

Data directory used inside the container. Defaults to `/var/lib/ldp`.