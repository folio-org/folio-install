FROM alpine:3.8

#Prerequisites
RUN apk add --no-cache curl perl perl-app-cpanminus perl-json perl-libwww

#Create working directories
RUN mkdir -p /usr/local/bin/folio
RUN mkdir -p /sample-data

#Set working directory
WORKDIR /usr/local/bin/folio

#Copy in scripts and files
COPY /sample-data/ /sample-data/
COPY load-data.pl /usr/local/bin/folio
COPY create-sampdata.sh /usr/local/bin/folio

#X-Okapi-Token variable for script
ENV X_OKAPI_TOKEN='default'

#Execute the script on container runtime
CMD ["/usr/local/bin/folio/create-sampdata.sh"]