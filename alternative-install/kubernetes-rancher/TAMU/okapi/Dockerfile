FROM maven:3.8.4-openjdk-17-slim

#Maven Prerequisites
RUN apt-get update && apt-get -y install curl git

#Okapi git clone and Maven build
RUN mkdir -p /usr/local/bin/folio/
WORKDIR /usr/local/bin/folio
RUN git clone  -b "v4.10.0" --recursive https://github.com/folio-org/okapi.git
RUN cd okapi && mvn clean install -DskipTests

#OpenJDK Alpine
FROM alpine:3.15.0

#Okapi Prerequisites
RUN apk add --no-cache curl openjdk11

#Copy in files at this build layer
RUN mkdir -p /usr/local/bin/folio/
COPY --from=0 /usr/local/bin/folio/okapi /usr/local/bin/folio/okapi

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

#Set environment variables for script
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

#Set working directory
WORKDIR /usr/local/bin/folio

#Copy in scripts and files
COPY hazelcast.xml /usr/local/bin/folio/okapi/
COPY startup.sh /usr/local/bin/folio/

#Execute the script on container runtime
CMD ["/usr/local/bin/folio/startup.sh"]
