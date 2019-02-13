FROM alpine:3.8

#Prerequisites
RUN apk add --no-cache curl postgresql-client

#Create working directory
RUN mkdir -p /usr/local/bin/folio

#Set working directory
WORKDIR /usr/local/bin/folio

#Copy in script
COPY create-db.sh /usr/local/bin/folio

#Set postgres password environment variables to give to psql
ENV PG_DATABASE='okapi'
ENV PG_USER='okapi'
ENV PG_PASSWORD='password'
ENV DB_HOST='pghost'
ENV DB_DATABASE='okapi_modules'
ENV DB_USERNAME='folio_admin'
ENV DB_PASSWORD='password'

#Execute the script on container runtime
CMD ["/usr/local/bin/folio/create-db.sh"]