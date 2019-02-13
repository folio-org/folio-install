#!/bin/sh

# set NAMESPACE in  hazelcast xml file
sed -i "s/NAMESPACE/$(echo "${NAMESPACE}" | envsubst)/g" $HAZELCAST_FILE;

if [ $INITDB = 'true' ]; then
    echo "InitDB"
    java -Dstorage=postgres -Dpostgres_host=$PG_HOST -Dpostgres_port=$PG_PORT -Dpostgres_username=$PG_USERNAME \
    -Dpostgres_password=$PG_PASSWORD -Dpostgres_database=$PG_DATABASE -Dhost=$OKAPI_HOST -Dport=$OKAPI_PORT -Dokapiurl=$OKAPI_URL \
    -Dnodename=$OKAPI_NODENAME -Dloglevel=$OKAPI_LOGLEVEL -jar okapi/okapi-core/target/okapi-core-fat.jar initdatabase

    sleep 1
    export OKAPI_CLUSTERHOST=$(hostname -i)
    export OKAPI_NODENAME=$(hostname)

    echo "Start Okapi after init"
    java -Dstorage=postgres -Dpostgres_host=$PG_HOST -Dpostgres_port=$PG_PORT -Dpostgres_username=$PG_USERNAME \
    -Dpostgres_password=$PG_PASSWORD -Dpostgres_database=$PG_DATABASE -Dhost=$OKAPI_HOST -Dport=$OKAPI_PORT -Dokapiurl=$OKAPI_URL \
    -Dnodename=$OKAPI_NODENAME -Dloglevel=$OKAPI_LOGLEVEL \
    -Dhazelcast.ip=$HAZELCAST_IP -Dhazelcast.port=$HAZELCAST_PORT \
    -jar okapi/okapi-core/target/okapi-core-fat.jar $OKAPI_COMMAND -cluster-host $OKAPI_CLUSTERHOST -cluster-port $HAZELCAST_VERTX_PORT -hazelcast-config-file $HAZELCAST_FILE

else
    export OKAPI_CLUSTERHOST=$(hostname -i)
    export OKAPI_NODENAME=$(hostname)

    echo "Start Okapi Only"
    java -Dstorage=postgres -Dpostgres_host=$PG_HOST -Dpostgres_port=$PG_PORT -Dpostgres_username=$PG_USERNAME \
    -Dpostgres_password=$PG_PASSWORD -Dpostgres_database=$PG_DATABASE -Dhost=$OKAPI_HOST -Dport=$OKAPI_PORT -Dokapiurl=$OKAPI_URL \
    -Dnodename=$OKAPI_NODENAME -Dloglevel=$OKAPI_LOGLEVEL \
    -Dhazelcast.ip=$HAZELCAST_IP -Dhazelcast.port=$HAZELCAST_PORT \
    -jar okapi/okapi-core/target/okapi-core-fat.jar $OKAPI_COMMAND -cluster-host $OKAPI_CLUSTERHOST -cluster-port $HAZELCAST_VERTX_PORT -hazelcast-config-file $HAZELCAST_FILE
fi