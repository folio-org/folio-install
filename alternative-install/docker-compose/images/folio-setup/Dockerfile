FROM alpine:3.8

#Prerequisites
RUN apk add --no-cache curl git perl

#Create working directory
RUN mkdir -p /usr/local/bin/folio

#Set working directory
WORKDIR /usr/local/bin/folio

# clone platform-complete
RUN git clone https://github.com/folio-org/platform-complete
RUN git clone https://github.com/folio-org/folio-install

#Copy in scripts and files
COPY setup.sh /usr/local/bin/folio

#Execute the script on container runtime
CMD ["/usr/local/bin/folio/setup.sh"]
