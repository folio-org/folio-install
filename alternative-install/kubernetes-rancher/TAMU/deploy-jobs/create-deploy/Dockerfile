FROM alpine:3.8

#Prerequisites
RUN apk add --no-cache curl

#Create folders in container
RUN mkdir -p /usr/local/bin/folio/deploy-descriptors
RUN mkdir -p /usr/local/bin/folio/module-descriptors
RUN mkdir -p /usr/local/bin/folio/tenant
RUN mkdir -p /usr/local/bin/folio/stripes/module-descriptors
RUN mkdir -p /usr/local/bin/folio/stripes/tenant

#Set working directory
WORKDIR /usr/local/bin/folio

#Copy in scripts and files
COPY create-deploy.sh /usr/local/bin/folio
COPY /module-descriptors/* /usr/local/bin/folio/module-descriptors/
COPY /tenant/* /usr/local/bin/folio/tenant/
COPY /stripes/module-descriptors/* /usr/local/bin/folio/stripes/module-descriptors/
COPY /stripes/tenant/* /usr/local/bin/folio/stripes/tenant/

#Set environment variables for script
ENV TENANT_ID='mytenant'
ENV OKAPI_URL='http://localhost:9130'

#Execute the script on container runtime
CMD ["/usr/local/bin/folio/create-deploy.sh"]