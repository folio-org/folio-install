FROM ubuntu
# Build FOLIO Stripes

#Set ARG Default
ARG stripestag=q3-2018

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

RUN n lts

# clone platform-complete
RUN git clone https://github.com/folio-org/platform-complete
RUN (cd platform-complete  && git checkout ${stripestag}  && yarn install && yarn upgrade --scope @folio)
ADD stripes.config.js /usr/local/bin/folio/stripes/platform-complete/stripes.config.js
RUN (cd platform-complete  && NODE_ENV=production yarn build output)

#Setup nginx stripes container
FROM nginx
COPY --from=0 /usr/local/bin/folio/stripes/platform-complete/output /usr/share/nginx/html/
ENV OKAPI_HOSTPORT localhost:9130
ENV OKAPI_TENANT diku
ENV OKAPI_SCHEME http
ADD setup_folio /setup_folio

CMD ["/setup_folio"]
