FROM alpine:3.15.0

#Upgrade all packages: https://pythonspeed.com/articles/security-updates-in-docker/
#Prerequisites
RUN apk upgrade \
 && apk add \
      curl \
 && rm -rf /var/cache/apk/*

#Create working directory
RUN mkdir -p /usr/local/bin/folio

#Set working directory
WORKDIR /usr/local/bin/folio

#Copy in script
COPY create-tenant.sh /usr/local/bin/folio

#Set environment variables for script
ENV OKAPI_URL='http://localhost:9130'
ENV TENANT_ID='mytenant'
ENV TENANT_NAME='full_tenant_name'
ENV TENANT_DESC='tenant_description'

#Execute the script on container runtime
CMD ["/usr/local/bin/folio/create-tenant.sh"]
