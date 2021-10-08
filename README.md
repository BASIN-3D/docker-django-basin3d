# docker-django-basin3d
Docker image definition for building a Django REST API BASIN-3D with public data plugins

*The official django-basin3d docker image, made in a collaboration with [ESS-DIVE](https://github.com/ess-dive)*

## What is django-basin3d?
*from [django-basin3d.readthedocs.org](https://django-basin3d.readthedocs.org)*

Django BASIN-3D is a software that synthesizes diverse earth science data from a variety of remote sources in real-time without the need for storing all the data in a single database. It is a data brokering framework designed to parse, translate, and synthesize diverse observations from well-curated repositories into standardized formats for scienfic uses such as analysis and visualization. Thus, it provides unified access to a diverse set of data sources and data types by connecting to the providers in real-time and transforming the data streams to provide an integrated view. BASIN-3D enables users to always have access to the latest data from each of the sources, but to deal with the data as if all of the data were integrated in local storage. Importantly users can integrate public data without establishing a prior working relationships with each data source.

Django BASIN-3D is an extendable Python/Django application that uses a generalized data synthesis model that applies across a variety of earth science observation types (hydrology, geochemistry, climate etc.) The synthesis models, BASIN-3D’s abstracted formats, are based on the Open Geospatial Consortium (OGC) and ISO “Observations and Measurements” (OGC 10-004r3 / ISO 19156: 2013) and OGC “Timeseries Profile of Observations and Measurement “(OGC 15-043r3) data standards. The synthesized data available via REpresentational State Transfer (REST) Application Programming Interfaces (API).

The current version of BASIN-3D can be used to integrate time-series earth science observations across a hierarchy of spatial locations. The use of the OGC/ISO framework makes BASIN-3D extensible to other data types, and in the future we plan to add support for remote sensing and gridded (e.g. model output) data. BASIN-3D is able to handle multiscale data, through the use of the OGC/ISO framework that allows for specification of hierarchies of spatial features (e.g., points, plots, sites, watersheds, basin). Thus, users can retrieve data for a specific point location or river basin.
## Build image
Vist https://github.com/BASIN-3D/django-basin3d/tags to determine the version of django-basin3d
to build

    VERSION=<tag>
    ./build.sh $VERSION
    
Build an image for a private repository

     VERSION=<tag>
     REGISTRY=registry.example.com  ./build.sh $VERSION
     
Build an image with specific UID and GID.

     VERSION=<tag>
     IMAGE_GID=75555 IMAGE_UID=75556 ./build.sh $VERSION
     
Note the image name and tag is formated `django-basin3d:<version>-p<num>` (e.g `django-basin3d:0.0.4-p2`)

    
    
## Test Image
Test image with the `runTests.sh`

    ./runTests.sh django-basin3d:<tag>
    **********
    SUCCESS!!
    **********
    ******************************
    Cleaning up testing artifacts
    ******************************
    edfc46a9e869a0004e2d89ef47545891de31b19b36e4efb8151ed60035738f52
    90d96d5674c1979e520d1ea7fec7653a13aafafb32fe1d4e432b7922a943dcc9
    edfc46a9e869a0004e2d89ef47545891de31b19b36e4efb8151ed60035738f52
    90d96d5674c1979e520d1ea7fec7653a13aafafb32fe1d4e432b7922a943dcc9
    test-network


## Usage
The following examples demonstrate how to run this image

The following is a very minimal example. Please refer to the 
[django-basin3d.readthedocs.org](https://django-basin3d.readthedocs.org)
documentation for more information about django-basin3d.

    docker run  \
       -p 8080:8080 \
       --name basin3d-app  -it django-basin3d:<tag>

The REST API should be able to be accessed at http://localhost:8080

# How to use this image

## Image Build Arguments
The following are the optional build arguments for this docker image.

**IMAGE_GID:** (default: 4999) the UID to run Django BASIN-3D service as. 

**IMAGE_UID:** (default: 5000 ) the UID to run Django BASIN-3D service as.

```
docker build --build-arg IMAGE_UID=<uid> 
    --build-arg IMAGE_GID=<gid>
```

## Image Environment Variables
The following environment variables are optional:

**ADMIN_USER:** the django superuser username. 

**ADMIN_EMAIL:** _(recommended)_ The email for the django superuser

**ADMIN_PASSWORD:** _(recommended)_ The password for the admin user

**ADMIN_PASSWORD_FILE:**  _(recommended)_ A file that contains the admin user password.  This file 
must be mountied inside the container.

**CSRF_COOKIE_SECURE:** Default is False (See https://docs.djangoproject.com/en/3.2/ref/settings/#csrf-cookie-secure)

**DJANGO_DEBUG:** Default is False. Set to True for setting Django app in debug mode .

**SECRET_KEY:** _(recommended)_ The session secret key for the Django application

**SESSION_COOKIE_SECURE:** Default is False (See https://docs.djangoproject.com/en/3.2/ref/settings/#session-cookie-secure)

### 
The following datbase environment variables are optional.  The container will
start up with a Sqllite DB by default.

**SQL_ENGINE:**  Default engine is sqlite

**SQL_DATABASE:** Default is `/app/basin3d_app/db.sqlite3`

**SQL_USER:** Default is `basin3d`

**SQL_PASSWORD:** Default is empty string

**SQL_HOST:** Default is localhost

**SQL_PORT:** Default is 5432


Run the docker container with a Postgres DB

    docker network create basin3d-network

    DB_NAME=basin3d
    DB_PASSWORD=basin3d
    docker run  \
       -p 5432:5432 \
       -e POSTGRES_PASSWORD=$DB_PASSWORD \
       -e POSTGRES_USER=$DB_NAME \
       --network basin3d-network -d \
       --name basin3d-db  -it postgres:alpine 
    
    docker run  \
           -p 8080:8080     \
           -e ADMIN_PASSWORD=changeme \
           -e SQL_ENGINE=django.db.backends.postgresql_psycopg2 \
           -e SQL_DATABASE=$DB_NAME \
           -e SQL_PASSWORD=$DB_PASSWORD \
           -e SQL_HOST=basin3d-db \
           --name basin3d-app  -d \
           --network=basin3d-network  \
           -it django-basin3d:<tag> 
           

The REST API should be able to be accessed at http://localhost:8080
    
Stop and remove running containers and network

    docker stop basin3d-app basin3d-db
    docker rm basin3d-app basin3d-db
    docker network rm basin3d-network
    
## Copyright

Broker for Assimilation, Synthesis and Integration of eNvironmental Diverse, Distributed Datasets (BASIN-3D) Copyright (c) 2019, The
Regents of the University of California, through Lawrence Berkeley National
Laboratory (subject to receipt of any required approvals from the U.S.
Dept. of Energy).  All rights reserved.

If you have questions about your rights to use or distribute this software,
please contact Berkeley Lab's Intellectual Property Office at
IPO@lbl.gov.

NOTICE.  This Software was developed under funding from the U.S. Department
of Energy and the U.S. Government consequently retains certain rights.  As
such, the U.S. Government has been granted for itself and others acting on
its behalf a paid-up, nonexclusive, irrevocable, worldwide license in the
Software to reproduce, distribute copies to the public, prepare derivative
works

# License

See [LICENSE](./LICENSE)

# Supported Docker versions

This image is officially supported on Docker Desktop 3.6.0


# People

Current Project [Team Members](https://github.com/orgs/BASIN-3D/teams/developers/members):


