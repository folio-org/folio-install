FROM alpine:3.11

#Prerequisites
RUN apk add --no-cache curl postgresql-client

#Create working directory
RUN mkdir -p /usr/local/bin/folio

#Set working directory
WORKDIR /usr/local/bin/folio

#Copy in script
COPY alter-db.sh /usr/local/bin/folio

#Set postgres password environment variables to give to psql
ENV PG_DATABASE='folio_db'
ENV PG_USER='foliodb_user'
ENV PG_PASSWORD='password'
ENV DB_HOST='pg-host'

#Execute the script on container runtime
CMD ["/usr/local/bin/folio/alter-db.sh"]
