# FOLIO Installation

The following is a docker-compose image build and deployment script. This should work on Windows, Mac, and Linux based systems. The deployment script has only been tested on Mac and Linux.

### Requirements

* Docker
* Docker Compose   

### Deployment FOLIO Backend

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

### Deployment FOLIO Frontend

1. Deploy FOLIO backend

        $ cd deployments/folio-frontend
        $ docker-compose up -d --build

2. Shutdown of frontend

        $ docker-compose down
