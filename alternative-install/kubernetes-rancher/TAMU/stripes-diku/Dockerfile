FROM ubuntu:18.04

#Prerequisites
RUN apt-get update && apt-get install -y curl gnupg apt-transport-https ca-certificates ssl-cert

#Yarn
RUN curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add -
RUN echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list
RUN apt-get update && apt-get install -y yarn

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
RUN yarn config set @folio:registry https://repository.folio.org/repository/npm-folio/
RUN yarn install
RUN yarn build --okapi $OKAPI_URL --tenant $TENANT_ID ./output

#Load balancer
FROM nginx:stable-alpine

#Expose the Stripes Nginx port
EXPOSE 3000

#Copy in files at this build layer
COPY --from=0 /usr/local/bin/folio/stripes/output /usr/share/nginx/html
COPY --from=0 /usr/local/bin/folio/stripes/yarn.lock /usr/share/nginx/html/yarn.lock 
COPY nginx.conf /etc/nginx/conf.d/default.conf

