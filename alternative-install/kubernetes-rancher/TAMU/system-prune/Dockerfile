FROM docker:17.03.2-ce
RUN apk update
RUN apk add bash
ENV DELAY_TIME=**None**

ADD run.sh /run.sh
RUN chmod 755 /run.sh
ENTRYPOINT ["/run.sh"]