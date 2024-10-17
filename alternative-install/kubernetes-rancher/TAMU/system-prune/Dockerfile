FROM docker:24.0.9
RUN apk update
RUN apk add bash
ENV DELAY_TIME=**None**

ADD run.sh /run.sh
RUN chmod 755 /run.sh
ENTRYPOINT ["/run.sh"]
