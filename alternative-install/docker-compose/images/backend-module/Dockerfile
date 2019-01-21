ARG ORG
ARG MODULE
ARG TAG
FROM "${ORG}/${MODULE}:${TAG}"
ARG MODULE
ARG TAG
ENTRYPOINT ["/usr/local/bin/docker-entrypoint"]

ENV START_CMD="./run-java.sh" \
  OKAPI_TRY_COUNT=120 \
  ENABLE_TRY_COUNT=120 \
  CURL_CONNECT_TIMEOUT=3 \
  SERVICE_ID=$MODULE-$TAG \
  INSTALL_ID=$MODULE-$TAG \
  SERVICE_URL=http://localhost:8081/ \
  FOLIO_REGISTRY='http://folio-registry.aws.indexdata.com/_/proxy/modules/' \
  SELF_DEPLOY=false

COPY docker-entrypoint /usr/local/bin/
