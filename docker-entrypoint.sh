#!/usr/bin/env bash

echo "********************************"
echo " BASIN-3D APP Docker Entrypoint "
echo "********************************"

# Loads the environment variables
source /usr/local/bin/docker-manage-entrypoint.sh

if [ "$DATABASE" = "postgres" ]
then
    echo "Waiting for postgres..."

    while ! nc -z ${SQL_HOST:-db} ${SQL_PORT:-5432}; do
      sleep 0.1
    done

    echo "PostgreSQL started"
fi

pip freeze

# Collect the static files
python manage.py collectstatic --no-input

# migrate django
python manage.py migrate

IS_LOADED=$(./manage.py shell -c "from django.contrib.auth.models import User; print(User.objects.count())")
echo "IS_LOADED:$IS_LOADED"

if [ "${IS_LOADED}" == "0" ];
then

    # Create a default superuser
    ./manage.py shell -c "from django.contrib.auth.models import User; User.objects.create_superuser('${ADMIN_USER:-admin}', '${ADMIN_EMAIL}', '${ADMIN_PASSWORD}')"
    echo "Admin superuser '${ADMIN_USER}' created"
fi

exec $@