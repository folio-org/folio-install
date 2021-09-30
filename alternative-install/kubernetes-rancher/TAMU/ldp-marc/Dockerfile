FROM debian:buster-slim

#LDP Marc Prerequisites
RUN apt update -y && apt install -y unixodbc odbc-postgresql odbc-postgresql libcurl4-openssl-dev

#Copy in built LDP Marc binary
COPY ./build/ldpmarc /bin/ldpmarc

#Execute the script on container runtime
ENTRYPOINT ["ldpmarc"]