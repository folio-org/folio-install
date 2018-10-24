#FROM "${ORG}/${MODULE}:${TAG}"
FROM folioci/mod-authtoken:1.4.1-SNAPSHOT.21
ADD deploy-enable-service.sh deploy-enable-service.sh

ENTRYPOINT ["./deploy-enable-service.sh"]
