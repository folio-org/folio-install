FROM alpine:3.9

#Prerequisites
RUN apk add --no-cache curl perl perl-app-cpanminus perl-json perl-libwww python py-pip
RUN pip install --upgrade pip
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
ENV ADMIN_PASSWORD='admin'
ENV ADMIN_USER='diku_admin'
ENV OKAPI_URL='http://okapi:9130'
ENV PURGE_DATA='true'
ENV REF_DATA='true'
ENV REGISTRY_URL='http://okapi:9130/_/proxy/modules'
ENV SAMPLE_DATA='true'
ENV TENANT_DESC='Danish Library Technology Institute'
ENV TENANT_ID='diku'
ENV TENANT_NAME='Datalogisk Institut'

#Execute the script on container runtime
CMD ["/usr/local/bin/folio/create-deploy.sh"]
