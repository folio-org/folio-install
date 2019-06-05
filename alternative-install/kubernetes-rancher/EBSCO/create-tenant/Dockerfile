FROM alpine:3.9

#Prerequisites
RUN apk add --no-cache curl

#Create working directory
RUN mkdir -p /usr/local/bin/folio

#Set working directory
WORKDIR /usr/local/bin/folio

#Copy in script
COPY create-tenant.sh /usr/local/bin/folio

#Set environment variables for script
ENV ADMIN_PASSWORD='admin'
ENV ADMIN_USER='diku_admin'
ENV OKAPI_URL='http://okapi:9130'
ENV PURGE_DATA='true'
ENV REF_DATA='true'
ENV REGISTRY_URL='http://okapi:9130/_/proxy/modules'
ENV SAMPLE_DATA='true'
ENV TENANT_DESC='Danish Library Technology Institute'
ENV TENANT_ID='diku'
ENV TENANT_NAME='Datalogisk Institut'

#Execute the script on container runtime
CMD ["/usr/local/bin/folio/create-tenant.sh"]
