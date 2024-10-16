FROM alpine/git:2.36.3

#Okapi git clone
RUN mkdir -p /usr/local/bin/folio
WORKDIR /usr/local/bin/folio
RUN git clone -b "v5.0.1" --recursive https://github.com/folio-org/okapi.git

#Maven build
FROM maven:3.8.7-eclipse-temurin-11
RUN mkdir -p /usr/local/bin/folio

#Copy in files at this build layer
COPY --from=0 /usr/local/bin/folio /usr/local/bin/folio

#Set working directory and run the Maven build
WORKDIR /usr/local/bin/folio/okapi
RUN mvn clean install -DskipTests

#OpenJDK Alpine
FROM alpine:3.17.1
RUN apk add --no-cache curl openjdk11

#Copy in files at this build layer
RUN mkdir -p /usr/local/bin/folio
COPY --from=1 /usr/local/bin/folio/okapi /usr/local/bin/folio/okapi

#Set working directory and copy in startup script and hazelcast config
WORKDIR /usr/local/bin/folio
COPY hazelcast.xml /usr/local/bin/folio/okapi/
COPY startup.sh /usr/local/bin/folio/

#Expose ports
EXPOSE 9130
EXPOSE 9150
EXPOSE 5701
EXPOSE 5702
EXPOSE 5703
EXPOSE 5704
EXPOSE 5705
EXPOSE 5706
EXPOSE 54327

#Set environment variables for startup
ENV INITDB='false'
ENV PG_HOST='localhost'
ENV PG_PORT='5432'
ENV PG_USERNAME='okapi'
ENV PG_PASSWORD='okapi25'
ENV PG_DATABASE='okapi'
ENV OKAPI_COMMAND='dev'
ENV OKAPI_PORT='9130'
ENV OKAPI_URL='http://localhost:9130'
ENV OKAPI_HOST='localhost'
ENV OKAPI_CLUSTERHOST='localhost'
ENV OKAPI_NODENAME='okapi1'
ENV OKAPI_LOGLEVEL='INFO'
ENV OKAPI_STORAGE='inmemory'
ENV HAZELCAST_FILE='/usr/local/bin/folio/okapi/hazelcast.xml'
ENV HAZELCAST_PORT='5701'
ENV HAZELCAST_VERTX_PORT='5702'
ENV HAZELCAST_IP='localhost'

#Execute the startup script on container runtime
CMD ["/usr/local/bin/folio/startup.sh"]
