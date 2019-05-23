FROM alpine:3.8

#Prerequisites
RUN apk add --no-cache curl

#Create folders in container
RUN mkdir -p /usr/local/bin/folio/disable

#Set working directory
WORKDIR /usr/local/bin/folio

#Copy in scripts and files
COPY delete-deploy.sh /usr/local/bin/folio
COPY /disable/* /usr/local/bin/folio/disable/

#Set environment variables for script
ENV TENANT_ID='mytenant'
ENV OKAPI_URL='http://localhost:9130'
ENV PURGE_DATA='false'

#Execute the script on container runtime
CMD ["/usr/local/bin/folio/delete-deploy.sh"]