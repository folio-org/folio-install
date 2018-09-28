#Prerequisites JDK
FROM openjdk:8

#Okapi Repo
RUN echo 'debconf debconf/frontend select Noninteractive' | debconf-set-selections
RUN apt-get update && apt-get install -y --no-install-recommends apt-utils
RUN apt-get update && apt-get install -y wget apt-transport-https ca-certificates python-apt ssl-cert dpkg

#Mvn
RUN apt-get update && apt-get install -y curl git maven unzip 

#Okapi git clone and MVN Build
RUN mkdir -p /usr/local/bin/folio/
WORKDIR /usr/local/bin/folio
RUN git clone  -b "v2.16.1" --recursive https://github.com/folio-org/okapi.git
RUN cd okapi && mvn clean install -DskipTests

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
ENV OKAPI_COMMAND='cluster'
ENV OKAPI_PORT='9130'
ENV OKAPI_URL='http://localhost:9130'
ENV OKAPI_HOST='localhost'
ENV OKAPI_CLUSTERHOST='localhost'
ENV OKAPI_NODENAME='okapi1'
ENV OKAPI_LOGLEVEL='DEBUG'
ENV HAZELCAST_FILE='/usr/local/bin/folio/okapi/hazelcast.xml'
ENV HAZELCAST_PORT='5701'
ENV HAZELCAST_VERTX_PORT='5703'
ENV HAZELCAST_IP='localhost'

#Copy in scripts and files
COPY hazelcast.xml /usr/local/bin/folio/okapi/
COPY startup.sh /usr/local/bin/folio/

#Execute the script on container runtime
CMD ["/usr/local/bin/folio/startup.sh"]
