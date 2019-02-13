FROM alpine:3.8

#Prerequisites
RUN apk add --no-cache curl perl perl-app-cpanminus perl-json perl-libwww

#Create working directories
RUN mkdir -p /usr/local/bin/folio
RUN mkdir -p /reference-data

#Set working directory
WORKDIR /usr/local/bin/folio

#Copy in scripts and files
COPY /reference-data/ /reference-data/
COPY load-data.pl /usr/local/bin/folio
COPY create-refdata.sh /usr/local/bin/folio

#Set environment variables for script
ENV TENANT_ID='mytenant'
ENV ADMIN_USER='tenant_admin'
ENV ADMIN_PASSWORD='password'
ENV OKAPI_URL='http://localhost:9130'

#Execute the script on container runtime
CMD ["/usr/local/bin/folio/create-refdata.sh"]