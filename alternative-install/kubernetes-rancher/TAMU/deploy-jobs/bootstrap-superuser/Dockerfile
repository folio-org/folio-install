FROM alpine:3.16

#Upgrade all packages: https://pythonspeed.com/articles/security-updates-in-docker/
#Prerequisites
RUN apk upgrade \
 && apk add \
      make curl perl perl-app-cpanminus perl-json perl-libwww \
 && rm -rf /var/cache/apk/*
RUN cpanm UUID::Tiny

#Create working directory
RUN mkdir -p /usr/local/bin/folio

#Set working directory
WORKDIR /usr/local/bin/folio

#Copy in scripts and files
COPY bootstrap-superuser.pl /usr/local/bin/folio
COPY create-superuser.sh /usr/local/bin/folio

#Set environment variables for script
ENV TENANT_ID='mytenant'
ENV ADMIN_USER='tenant_admin'
ENV ADMIN_PASSWORD='password'
ENV OKAPI_URL='http://localhost:9130'

#Execute the script on container runtime
CMD ["/usr/local/bin/folio/create-superuser.sh"]
