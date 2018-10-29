ARG ORG
ARG MODULE
ARG TAG
FROM "${ORG}/${MODULE}:${TAG}"

ENV START_CMD="./run-java.sh"
ADD deploy-enable-service.sh deploy-enable-service.sh
ENTRYPOINT ["./deploy-enable-service.sh"]
