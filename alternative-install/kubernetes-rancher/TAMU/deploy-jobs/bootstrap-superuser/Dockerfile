FROM alpine:3.8

#Prerequisites
RUN apk add --no-cache make curl perl perl-app-cpanminus perl-json perl-libwww
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