FROM ubuntu

#Prerequisites
RUN apt-get update && apt-get install -y nodejs npm
RUN npm install -g n mocha
RUN apt-get update && apt-get install -y curl vim git apt-transport-https ca-certificates python-apt ssl-cert

#Yarn
RUN curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add -
RUN echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list
RUN apt-get update && apt-get install yarn

#Create working directory
RUN mkdir -p /usr/local/bin/folio/stripes

#Set ARG defaults for Stripes platform URL and branch
ARG STRIPES_PLATFORM=https://github.com/folio-org/platform-complete
ARG STRIPES_BRANCH=q4-2018

#Set working directory
WORKDIR /usr/local/bin/folio/stripes
RUN git clone --recursive $STRIPES_PLATFORM . && git checkout $STRIPES_BRANCH

#Copy in files at this build layer
COPY yarn.lock /usr/local/bin/folio/stripes/
COPY package.json /usr/local/bin/folio/stripes/
COPY stripes.config.js /usr/local/bin/folio/stripes/

RUN n lts

#Set ARG defaults for Stripes build
ARG TENANT_ID=mytenant
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