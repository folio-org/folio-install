FROM python:3-alpine

#Upgrade all packages: https://pythonspeed.com/articles/security-updates-in-docker/
#Prerequisites
RUN apk upgrade \
 && apk add \
      curl perl perl-app-cpanminus perl-json perl-libwww \
 && rm -rf /var/cache/apk/*
RUN pip install requests

#Create folders in container
RUN mkdir -p /usr/local/bin/folio/install

#Set working directory
WORKDIR /usr/local/bin/folio

#Copy in scripts and files
COPY create-deploy.sh /usr/local/bin/folio
COPY create-deploy-desc.py /usr/local/bin/folio
COPY /install/* /usr/local/bin/folio/install/

#Set environment variables for script
ENV TENANT_ID='mytenant'
ENV OKAPI_URL='http://localhost:9130'
ENV REGISTRY_URL='http://localhost:9130/_/proxy/modules'
ENV SAMPLE_DATA='false'
ENV REF_DATA='false'
ENV IGNORE_ERRORS='false'

#Execute the script on container runtime
CMD ["/usr/local/bin/folio/create-deploy.sh"]
