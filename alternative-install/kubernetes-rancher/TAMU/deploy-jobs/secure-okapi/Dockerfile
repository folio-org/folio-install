FROM alpine:3.8

#Prerequisites
RUN apk add --no-cache curl

#Create working directory
RUN mkdir -p /usr/local/bin/folio

#Set working directory
WORKDIR /usr/local/bin/folio

#Copy in scripts and files
COPY secure-okapi.sh /usr/local/bin/folio

#Set environment variables for script
ENV OKAPI_URL='http://localhost:9130'
ENV SUPER_USR='superuser'
ENV SUPER_PSSWD='password'

#Execute the script on container runtime
CMD ["/usr/local/bin/folio/secure-okapi.sh"]