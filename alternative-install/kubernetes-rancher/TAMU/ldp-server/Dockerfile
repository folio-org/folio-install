FROM debian:buster-slim

#Set data directory env var
ENV DATADIR='/var/lib/ldp'

#Create data directory for temp extraction
RUN mkdir -p $DATADIR

#LDP Prerequisites
RUN apt update -y && apt install -y unixodbc odbc-postgresql odbc-postgresql libcurl4-openssl-dev

#Copy in built LDP binary
COPY ./build/ldp /bin/ldp

#Execute the script on container runtime
ENTRYPOINT ["ldp"]