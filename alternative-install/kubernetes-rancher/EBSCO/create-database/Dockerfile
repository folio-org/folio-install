FROM alpine:3.9

#Prerequisites
RUN apk add --no-cache curl postgresql-client

#Create working directory
RUN mkdir -p /usr/local/bin/folio

#Set working directory
WORKDIR /usr/local/bin/folio

#Copy in script
COPY create-db.sh /usr/local/bin/folio

#Set postgres password environment variables to give to psql
ENV PG_MASTER_USER='postgres'
ENV PG_MASTER_USER_PASSWORD='password'
ENV PG_OKAPI_USER='okapi'
ENV PG_OKAPI_USER_PASSWORD='okapi25'
ENV PG_FOLIO_ADMIN_USER='folio_admin'
ENV PG_FOLIO_ADMIN_USER_PASSWORD='password'
ENV PG_DATABASE_OKAPI='okapi'
ENV PG_DATABASE_OKAPI_MODULES='okapi_modules'

ENV PG_DB_HOST='remote_AWS_HOST'

#Execute the script on container runtime
CMD ["/usr/local/bin/folio/create-db.sh"]
