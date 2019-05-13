#!/usr/bin/env bash

source b-log.sh
LOG_LEVEL_INFO

LOG_FILE=$1

B_LOG --file ${LOG_FILE}

cd {{ nextcloud_docker_project_dir }}

INFO "Going in maintenance mode"
docker-compose exec -u www-data app ./occ maintenance:mode --on | INFO

INFO "Recreating database ..."
docker-compose exec db sh -c 'mysql -e "DROP DATABASE nextcloud"' | INFO
docker-compose exec db sh -c 'mysql -e "CREATE DATABASE nextcloud"' | INFO

INFO "Restoring database ..."
docker-compose exec db sh -c 'mysql nextcloud < /backup/nextcloud.bak' | INFO

INFO "Restoring data ..."
docker-compose exec app rsync -aqx /backup/data /var/www/html/data | INFO

INFO "Exiting maintenance mode"
docker-compose exec -u www-data app ./occ maintenance:mode --off | INFO

exit 0