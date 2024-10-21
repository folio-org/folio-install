FROM docker:latest

# Install latest patch versions of packages: https://pythonspeed.com/articles/security-updates-in-docker/
RUN apk upgrade \
 && apk add \
      bash \
 && rm -rf /var/cache/apk/*

ENV DELAY_TIME=**None**

ADD run.sh /run.sh
RUN chmod 755 /run.sh
ENTRYPOINT ["/run.sh"]
