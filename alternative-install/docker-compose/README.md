# FOLIO Installation

The following is a docker-compose image build and deployment script. This should work on Windows, Mac, and Linux based systems. The deployment script has only been tested on Mac and Linux. The orchestration ultimate goal is to provide a streamline install and generate the needed YAML for Kubernetes cluster deployment.

## Quick Setup and Install (TLDR)
#### Requirements

* Docker
    * Under docker preferences set the amount of memory docker can use to at least 8GB
    * Set CPU count to at least 2
* Docker Compose   

    The current environmental variables are set to produce the Q3 2018 release. The folio-backend deployment and initialization of DB with sample data usually takes around 5-6 mins to complete. If you wish to watch, the deployment activity, start the backend deployment and run the following command. 

        $ docker-compose logs -f

#### Deployment FOLIO Backend

1. Deploy FOLIO backend

        $ cd deployments/folio-backend
        $ docker-compose up -d --build

    The --build argument will force docker-compose to build all images prior to deployment. After the initial deployment --build is not needed.

    The .env file and the files within the config folder are used to set ENVIRONMENTAL Variables.

    After the initial deployment:

        LOAD_SAMPLEDATA=false
        INITDB=false

2. Shutdown System

        $ docker-compose down

    This will bring down system and leave the volume data intact.

        $ docker-compose down -v

    The -v will delete all volumes (Postgres database). You will need to reset the above variables to true.

        LOAD_SAMPLEDATA=true
        INITDB=true


#### Deployment FOLIO Frontend

1. Deploy FOLIO frontend

        $ cd deployments/folio-frontend
        $ docker-compose up -d --build

2. Shutdown of frontend

        $ docker-compose down

## FOLIO detailed build and deploy

#### Docker Compose

 Docker Compose overview [docker-compose](https://docs.docker.com/compose/overview/) definition.

    "Compose is a tool for defining and running multi-container Docker applications.
    With Compose, you use a YAML file to configure your application’s services.
    Then, with a single command, you create and start all the services from your configuration."

#### Deployment goals

1. Create FOLIO docker containers to be autonomous. The docker containers can exist without dependencies. Dependencies are essential, but the actual container can live without dependencies and continue to check for dependency resolution. Thus the deployed system will handle dependencies with the concept of eventual dependency resolution(EDR).

    * Okapi will handle and inform each module dependencies and provide feedback allowing EDR.

2. The docker-compose YAML file provides a mechanism to orchestrate services needed within the FOLIO system.
    * The critical item within this goal is the production Kubernetes YAML which will be used to deploy Kubernetes cluster.
    * Kompose will be used to create Kubernetes YAML files.

#### Docker images
1. PostgreSQL

    Image uses [postres official repository](https://hub.docker.com/_/postgres/).

        FROM Image: postgres:9.6
        startup: Creates Users, Role, and Database for okapi and folio

    Dockerfile and startup scripts available - [postgres build](./images/postgres/)
2. Okapi
 Image uses [maven official repository](https://hub.docker.com/_/maven/).

        FROM Image: maven:3.5.4-jdk-8-alpine
        Starup: Depending on ENV variables initializes DB or start okapi

 Dockerfile and startup scripts available - [okapi build](./images/okapi/)

3. Folio Setup

    Image uses [ubuntu official repository](https://hub.docker.com/_/ubuntu/).

            FROM Image: ubuntu:16.04
            Starup: Start up currently performs Folio registry pull,Tenant creation,
            Tenant superuser, load sample data, and enable stripes module.
            Please see Okapi sections for specific interactions.
    Dockerfile and startup scripts available - [folio-setup](./images/folio-setup/)
    > OKAPI Interaction:
    >1.  Pull FOLIO registry
    >
    >           POST "OKAPI_URL/_/proxy/pull/modules"
    >           DATA {"urls":["http://folio-registry.aws.indexdata.com"]}
    >
    >
    >2. Create Tenant (*Possible move to separate orchestration module component)
    >
    >            POST "OKAPI_URL/_/proxy/tenants"
    >           DATA Tenant id, name, and description in json format
    >
    >3. Enable Backend Modules for Tenant (*Possible move to separate orchestration module component)
    >
    >           POST "OKAPI_URL/_/proxy/tenants/OKAPI_TENANT/modules"
    >           DATA Backend modules
    >
    > 4.  Stripes module enable (*This action will be moved to the stripes frontend container)
    >
    >           POST "OKAPI_URL/_/proxy/tenants/OKAPI_TENANT/install?preRelease=false"
    >           DATA git repo 'platform-complete' branch based on ENV variable
    >
    > 5. Load Sample Data (*Possible move to separate orchestration module component)
    >
    >        Data for within git repo 'folio-install'. Branch dependent on ENV variable

4. Backend modules

    Image uses [folioorg](https://hub.docker.com/_/folioorg/) and/or [folioci](https://hub.docker.com/_/folioci/).

            FROM Image(example): folioorg/mod-authtoken:1.5.2
            Startup: Startup registers the DEPLOY_DESCRIPTOR with Okapi
            Please see OKAPI Interaction.
    Dockerfile and startup scripts available - [backend-module](./images/backend-module/)
    >OKAPI Interaction:
    >
    >1. Check if module is already registered.
    >
    >           GET "$OKAPI_URL/_/discovery/modules/$MODULE-$TAG"
    >
    >2. If not registered
    >
    >           POST "$OKAPI_URL/_/discovery/modules"
    >           DATA {"srvcId":"$MODULE-$TAG","instId":"$MODULE-$TAG","url":"$MODULE_URL"}
    >           TIMEOUT - If dependency problems runs a timeout and retry

5. Stripes Frontend

    Stripes is a mulit-build container. Stripes builds using [ubuntu](https://hub.docker.com/_/ubuntu/) image with the final stage uses [nginx](https://hub.docker.com/_/nginx/) web server container.

            Startup: Sets OKAPI URL and OKAPI TENANT within stripes bundle
    >OKAPI Interaction
    >        
    >     TODO: This should enable the frontend module with okapi. Pull this out of folio-setup.

#### Environmental variables

1. Location
    1. .env file
        * this file is used to configure docker-compose.yml file
    2. config/*.env files
        * These files are used to set recurring variables within containers
2. Variable definition
    This is still a work in progress. The environmental variables still need to be cleaned up. Duplicate variables are currently required.

    1. .env file

            # OKAPI Version Release Tag
            OKAPI_TAG=v2.18.0

            #Branch Tag for git repo
            PLATFORM_COMPLETE_TAG=q3-2018
            FOLIO_INSTALL_TAG=q3-2018-2

            # Load sample data from folio-install
            LOAD_SAMPLEDATA=true
            INITDB=true

            #internal cluster OKAPI URL
            OKAPI_URL=http://okapi:9130
            OKAPI_TENANT=diku

            #Exposed okapi port on HOST
            OKAPI_PORT_HOST=9130

            #Backend Modules

            #auth example
            MOD_AUTHTOKEN_MODULE=mod-authtoken
            MOD_AUTHTOKEN_TAG=1.5.2
            MOD_AUTHTOKEN_ORG=folioorg
            MOD_AUTHTOKEN_URL=http://mod-authtoken:8081
            ...
    2. config/*.env files

      This can be added to a service within docker-compose.yml file that are repeatable within multiple containers. For example if backend module needs a database connection.

            env_file:
              - ./config/folio-db.env


### Network

docker-compose creates a default network which deployed containers within network can access each other by service name.

Example:

    #auth example
    Service name: 'mod-authtoken'
    Okapi Endpoint: http://mod-authtoken:8081

### How to update or add modules

1. Update (Requires Restart)

        #within env file update tag
        MOD_AUTHTOKEN_TAG=1.5.3

2. Add New Module

    Creation of the .env and docker-compose.yml can be scripted with ansible. Could also include .env and docker-compose.yml within folio-install repos for regular folio releases.

    1. add variables to .env file

            # Add Env variables to .env files
            #mymodule example
            MOD_MYMODULE_MODULE=mod-mymodule
            MOD_MYMODULE_TAG=1.0.6
            MOD_MYMODULE_ORG=folioorg
            MOD_MYMODULE_URL=http://mod-mymodule:8081

    2. Add Service to docker-compose.yml

            mod-mymodule:
              image: ${MOD_MYMODULE_ORG}/${MOD_MYMODULE_MODULE}:${MOD_MYMODULE_TAG}
              container_name: folio-mod-mymodule
              build:
                context: ../../images/backend-module
                args:
                  - ORG=${MOD_MYMODULE_ORG}
                  - MODULE=${MOD_MYMODULE_MODULE}
                  - TAG=${MOD_MYMODULE_TAG}
              env_file:
                - ./config/folio-db.env
              environment:
                - OKAPI_URL=${OKAPI_URL}
                - OKAPI_TENANT=${OKAPI_TENANT}
                - ORG=${MOD_MYMODULE_ORG}
                - MODULE=${MOD_MYMODULE_MODULE}
                - TAG=${MOD_MYMODULE_TAG}
                - MODULE_URL=${MOD_MYMODULE_URL}
              depends_on:
                - okapi
                - folio-db

### Kubernetes

Kubernetes deployment script is generated from docker-compose.yml file.

1. Variable substitution: Can check output.  

        $ docker-compose config

2. YAML generation using Kompose

        $ mkdir kompose
        $ docker-compose config |kompose convert --out kompose/

    This procedure will create the YAML files to deploy to Kubernetes.


### Rancher 2.0
This section has only been tested on Mac. Will add and refine documentation with expanded deployment to AWS.

###### Installation

1. Rancher

        docker run -d --restart=unless-stopped \
        -p 80:80 -p 443:443 \
        rancher/rancher:latest


2. Rancher cli

    Rancher cli [documentation](https://rancher.com/docs/rancher/v2.x/en/cli/)

###### Deploy Rancher project create cluster (Local Mac tested)

1. Create rancher project
2. Create cluster
3. Context switch to folio-project

        mast4541@cu-norlin3-128:.../folio-backend$ rancher context switch
        NUMBER    CLUSTER NAME   PROJECT ID            PROJECT NAME    PROJECT DESCRIPTION
        1         local          local:p-l2w5l         folio-project
        2         local          local:p-rh54t         System          System project created for the cluster
        3         local          local:p-tft5q         cybercom
        4         local          local:project-ff6jr   Default         Default project created for the cluster
        Select a Project: 1
4. Kubectl create

        $ cd kompose
        mast4541@cu-norlin3-128:.../folio-backend/kompose$ rancher kubectl create -f .
        persistentvolumeclaim "folio-db-claim1" created
        configmap "folio-db-config-folio-db-env" created
        deployment.extensions "folio-db" created
        persistentvolumeclaim "folio-pgdata" created
        configmap "folio-setup-config-folio-okapi-env" created
        configmap "folio-setup-config-folio-setup-env" created
        deployment.extensions "folio-setup" created
        configmap "mod-authtoken-config-folio-db-env" created
        deployment.extensions "mod-authtoken" created
        configmap "mod-calendar-config-folio-db-env" created
        deployment.extensions "mod-calendar" created
        configmap "mod-circulation-config-folio-db-env" created
        deployment.extensions "mod-circulation" created
        configmap "mod-circulation-storage-config-folio-db-env" created
        deployment.extensions "mod-circulation-storage" created
        configmap "mod-codex-ekb-config-folio-db-env" created
        deployment.extensions "mod-codex-ekb" created
        configmap "mod-codex-inventory-config-folio-db-env" created
        deployment.extensions "mod-codex-inventory" created
        configmap "mod-codex-mux-config-folio-db-env" created
        deployment.extensions "mod-codex-mux" created
        configmap "mod-configuration-config-folio-db-env" created
        deployment.extensions "mod-configuration" created
        configmap "mod-feesfines-config-folio-db-env" created
        deployment.extensions "mod-feesfines" created
        configmap "mod-finance-config-folio-db-env" created
        deployment.extensions "mod-finance" created
        configmap "mod-inventory-config-folio-db-env" created
        deployment.extensions "mod-inventory" created
        configmap "mod-inventory-storage-config-folio-db-env" created
        deployment.extensions "mod-inventory-storage" created
        configmap "mod-kb-ebsco-config-folio-db-env" created
        deployment.extensions "mod-kb-ebsco" created
        configmap "mod-login-config-folio-db-env" created
        deployment.extensions "mod-login" created
        configmap "mod-login-saml-config-folio-db-env" created
        deployment.extensions "mod-login-saml" created
        configmap "mod-notes-config-folio-db-env" created
        deployment.extensions "mod-notes" created
        configmap "mod-notify-config-folio-db-env" created
        deployment.extensions "mod-notify" created
        configmap "mod-permissions-config-folio-db-env" created
        deployment.extensions "mod-permissions" created
        configmap "mod-rtac-config-folio-db-env" created
        deployment.extensions "mod-rtac" created
        configmap "mod-tags-config-folio-db-env" created
        deployment.extensions "mod-tags" created
        configmap "mod-user-import-config-folio-db-env" created
        deployment.extensions "mod-user-import" created
        configmap "mod-users-bl-config-folio-db-env" created
        deployment.extensions "mod-users-bl" created
        configmap "mod-users-config-folio-db-env" created
        deployment.extensions "mod-users" created
        configmap "mod-vendors-config-folio-db-env" created
        deployment.extensions "mod-vendors" created
        persistentvolumeclaim "okapi-claim0" created
        configmap "okapi-config-folio-db-env" created
        configmap "okapi-config-folio-okapi-env" created
        deployment.extensions "okapi" created
        service "okapi" created

5. Show Deployments

        mast4541@cu-norlin3-128:.../folio-backend/kompose$ rancher kubectl get deployments
        NAME                      DESIRED   CURRENT   UP-TO-DATE   AVAILABLE   AGE
        folio-db                  1         1         1            1           12m
        folio-setup               1         1         1            1           12m
        mod-authtoken             1         1         1            1           12m
        mod-calendar              1         1         1            1           12m
        mod-circulation           1         1         1            1           12m
        mod-circulation-storage   1         1         1            1           12m
        mod-codex-ekb             1         1         1            1           12m
        mod-codex-inventory       1         1         1            1           12m
        mod-codex-mux             1         1         1            1           12m
        mod-configuration         1         1         1            1           12m
        mod-feesfines             1         1         1            1           12m
        mod-finance               1         1         1            1           12m
        mod-inventory             1         1         1            1           12m
        mod-inventory-storage     1         1         1            1           12m
        mod-kb-ebsco              1         1         1            1           12m
        mod-login                 1         1         1            1           12m
        mod-login-saml            1         1         1            1           12m
        mod-notes                 1         1         1            1           12m
        mod-notify                1         1         1            1           12m
        mod-permissions           1         1         1            1           12m
        mod-rtac                  1         1         1            1           12m
        mod-tags                  1         1         1            1           12m
        mod-user-import           1         1         1            1           12m
        mod-users                 1         1         1            1           12m
        mod-users-bl              1         1         1            1           12m
        mod-vendors               1         1         1            1           12m
        okapi                     1         1         1            1           12m

6. Kubectl Shutdown

        mast4541@cu-norlin3-128:.../folio-backend/kompose$ rancher kubectl delete -f .
        persistentvolumeclaim "folio-db-claim1" deleted
        configmap "folio-db-config-folio-db-env" deleted
        deployment.extensions "folio-db" deleted
        persistentvolumeclaim "folio-pgdata" deleted
        configmap "folio-setup-config-folio-okapi-env" deleted
        configmap "folio-setup-config-folio-setup-env" deleted
        deployment.extensions "folio-setup" deleted
        configmap "mod-authtoken-config-folio-db-env" deleted
        ...
