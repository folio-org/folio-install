FROM alpine:3.11

#Prerequisites
RUN apk add --no-cache curl

#Create working directory
RUN mkdir -p /usr/local/bin/folio

#Set working directory
WORKDIR /usr/local/bin/folio

#Copy in script
COPY create-config.sh /usr/local/bin/folio

#Set environment variables for script
ENV EMAIL_FROM='noreply@folio.org'
ENV EMAIL_PASSWORD='password'
ENV EMAIL_SMTP_HOST='localhost'
ENV EMAIL_SMTP_PORT='502'
ENV EMAIL_USERNAME='login'
ENV EMAIL_SMTP_LOGIN_OPTION='DISABLED'
ENV EMAIL_TRUST_ALL='true'
ENV EMAIL_SMTP_SSL='false'
ENV EMAIL_START_TLS_OPTIONS='NONE'
ENV OKAPI_URL='http://localhost:9130'
ENV TENANT_ID='mytenant'
ENV X_OKAPI_TOKEN='foo'
ENV FOLIO_HOST='http://localhost:3000'
ENV SERVICE_POINT='UUID'
ENV SELF_CHECKOUT_CONFIG='config'
ENV ACS_TENANT_CONFIG='config'

#Execute the script on container runtime
CMD ["/usr/local/bin/folio/create-config.sh"]
