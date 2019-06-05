#Run command Example
docker run -it --mount src="$(pwd)",target=/usr/local/bin/folio.yaml.builder,type=bind maven:3.6.1-jdk-8-alpine /bin/bash

In the docker container
cd /usr/local/bin/folio.yaml.builder
mvn clean compile exec:java -Dexec.args="-o=backend-modules.yaml -i=okapi-install.json -i=install-extras.json -g=mod-agreements,mod-licenses"

exit
