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

#Set working directory
WORKDIR /usr/local/bin/folio/stripes
RUN git clone --recursive http://github.com/folio-org/folio-testing-platform.git .

#Copy in files at this build layer
COPY yarn.lock /usr/local/bin/folio/stripes/
COPY package.json /usr/local/bin/folio/stripes/
COPY stripes.config.js /usr/local/bin/folio/stripes/

RUN n lts

#Build Stripes
ENV NODE_OPTIONS="--max-old-space-size=4096"
ENV NODE_ENV='production'
RUN yarn install
RUN yarn build output

#Load balancer
FROM nginx:stable-alpine

#Copy in files at this build layer
COPY --from=0 /usr/local/bin/folio/stripes/output /usr/share/nginx/html
COPY --from=0 /usr/local/bin/folio/stripes/yarn.lock /usr/share/nginx/html/yarn.lock 
COPY nginx.conf /etc/nginx/conf.d/default.conf