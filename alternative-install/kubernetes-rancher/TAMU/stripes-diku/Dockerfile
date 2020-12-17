FROM ubuntu:18.04

#Prerequisites
RUN apt-get update && apt-get -y install wget curl nodejs npm gnupg apt-transport-https ca-certificates ssl-cert software-properties-common
RUN npm install n -g

#Yarn
RUN wget --quiet -O - https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add -
RUN add-apt-repository "deb https://dl.yarnpkg.com/debian/ stable main"
RUN apt-get update && apt-get -y install yarn

#Create working directory
RUN mkdir -p /usr/local/bin/folio/stripes

#Set working directory
WORKDIR /usr/local/bin/folio/stripes

#Copy in files at this build layer
COPY yarn.lock /usr/local/bin/folio/stripes/
COPY package.json /usr/local/bin/folio/stripes/
COPY stripes.config.js /usr/local/bin/folio/stripes/
COPY /tenant-assets/logo.png /usr/local/bin/folio/stripes/tenant-assets/
COPY /tenant-assets/favicon.png /usr/local/bin/folio/stripes/tenant-assets/

#Set ARG defaults for Stripes build
ARG TENANT_ID=diku
ARG OKAPI_URL=http://localhost:9130

#Build Stripes
RUN n lts
RUN yarn config set @folio:registry https://repository.folio.org/repository/npm-folio/
RUN yarn install --update-checksums
RUN yarn build --okapi $OKAPI_URL --tenant $TENANT_ID ./output

#Load balancer
FROM nginx:stable-alpine

#Expose the Stripes Nginx port
EXPOSE 3000

#Copy in files at this build layer
COPY --from=0 /usr/local/bin/folio/stripes/output /usr/share/nginx/html
COPY --from=0 /usr/local/bin/folio/stripes/yarn.lock /usr/share/nginx/html/yarn.lock 
COPY nginx.conf /etc/nginx/conf.d/default.conf
