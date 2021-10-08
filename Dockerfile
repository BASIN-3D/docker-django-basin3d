ARG PYTHON_VERSION=3.8.5
FROM python:${PYTHON_VERSION}
MAINTAINER Valerie Hendrix <vchendrix@lbl.gov>

# Docker Image Arguments
#  These may be overriden when
#  The image is build
ARG IMAGE_UID=4999
ARG IMAGE_GID=5000
ARG DJANGO_BASIN3D_VERSION=0.0.4

# set environment varibles
ENV PYTHONDONTWRITEBYTECODE 1
ENV PYTHONUNBUFFERED 1

# The working directory where the
# Application is copied
WORKDIR /app

# Run OS updates
# create unprivileged user, create application directories, and ensure proper permissions
# Install application dependencies
RUN apt-get update &&  apt-get install -y --no-install-recommends  netcat git \
    && rm -rf /var/lib/apt/lists/* \
    && groupadd -g ${IMAGE_GID} webapp \
    && useradd -u ${IMAGE_UID} -g ${IMAGE_GID} -c 'Web app User'  --no-create-home webapp \
    && chown webapp:webapp /app \
    && chmod g+s  /app


#Install the application dependencies
RUN pip install --upgrade pip && \
    pip install psycopg2-binary && \
    pip install git+https://github.com/BASIN-3D/django-basin3d.git@$DJANGO_BASIN3D_VERSION#egg=django-basin3d && \
    python -c "from django.core.management import execute_from_command_line;  execute_from_command_line()" startproject  basin3d_app /app && \
    pip install uwsgi uwsgitop && \
    mkdir /app/static&& \
    chown webapp:webapp /app/static

ADD ./basin3d_app /app/basin3d_app
ADD ./image_version.yml .


COPY ./docker-entrypoint.sh /usr/local/bin/
RUN ln -s usr/local/bin/docker-entrypoint.sh / # backwards compat

# This can be used for executing manage.py commands in a crom
COPY ./docker-manage-entrypoint.sh /usr/local/bin/
RUN ln -s usr/local/bin/docker-manage-entrypoint.sh / # backwards compat

ENTRYPOINT ["/usr/local/bin/docker-entrypoint.sh"]
CMD ["uwsgi", "--module", "basin3d_app.wsgi:application", "--http-socket", "0.0.0.0:8080", "--static-map", "/static=/app/static", "--processes=4"]

USER webapp