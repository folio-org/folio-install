FROM alpine:3.8

#Prerequisites
RUN apk add --no-cache curl

#Create working directory
RUN mkdir -p /usr/local/bin/folio

#Set working directory
WORKDIR /usr/local/bin/folio

#Copy in scripts and files
COPY tenant.json /usr/local/bin/folio
COPY create-tenant.sh /usr/local/bin/folio

#Execute the script on container runtime
CMD ["/usr/local/bin/folio/create-tenant.sh"]