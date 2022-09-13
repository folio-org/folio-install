FROM alpine:3.16

#Upgrade all packages: https://pythonspeed.com/articles/security-updates-in-docker/
#Prerequisites
RUN apk upgrade \
 && apk add \
      curl \
 && rm -rf /var/cache/apk/*

#Create working directory
RUN mkdir -p /usr/local/bin/folio/install
RUN mkdir -p /usr/local/bin/folio/deploy-descriptors

#Set working directory
WORKDIR /usr/local/bin/folio

#Copy in scripts and files
COPY secure-okapi.sh /usr/local/bin/folio
COPY /install/* /usr/local/bin/folio/install/

#Set environment variables for script
ENV OKAPI_URL='http://localhost:9130'
ENV SUPER_USR='superuser'
ENV SUPER_PSSWD='password'
ENV TENANT_ID='supertenant'
ENV SAMPLE_DATA='false'
ENV REF_DATA='true'

#Execute the script on container runtime
CMD ["/usr/local/bin/folio/secure-okapi.sh"]
