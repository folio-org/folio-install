FROM alpine:3.8

#Prerequisites
RUN apk add --no-cache curl postgresql-client

#Create working directory
RUN mkdir -p /usr/local/bin/folio

#Set working directory
WORKDIR /usr/local/bin/folio

#Copy in scripts and files
COPY okapi_modules.dmp /usr/local/bin/folio
COPY create-db.sh /usr/local/bin/folio

#Set postgres password environment variable to give to psql
ENV PG_PASSWORD='<Postgres root user DB password>'

#Execute the script on container runtime
CMD ["/usr/local/bin/folio/create-db.sh"]