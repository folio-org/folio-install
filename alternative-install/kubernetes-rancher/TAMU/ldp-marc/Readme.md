## Build Docker image

`docker build -t mod-ldpmarc .`


### Linux console run command ###

`docker run --rm -d --network folio-clustered --name mod-ldp -h mod-ldpmarc mod-ldpmarc`


### Setting the LDP Marc container command ###

The most common usage is: ```-f <odbc_file> -d <dsn> -u <ldp_user>``` where ```<odbc_file>``` is an ODBC data source file name such as ```$HOME/.odbc.ini``` or ```/etc/odbc.ini```, ```<dsn>``` is the ODBC data source name for the LDP database, and ```<ldp_user>``` is the LDP user to be granted select privileges on the output table.

For example:

```-f ~/.odbc.ini -d ldp_db -u ldp```

### Configuration file volume mount requirements ###

For K8s deployment, you will need to mount a configMap or Secret inside the container as a volume, passing in the contents of your odbc.ini file. An example of the config file contents might be:

```
[ldp]
Description = ldp
Driver = PostgreSQL
Database = ldp
Servername = pg-ldp
UserName = ldpadmin
Password = <ldpadmin_password>
Port = 5432
SSLMode = disable
```