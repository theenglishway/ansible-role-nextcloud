#!/usr/bin/env bash

source b-log.sh
LOG_LEVEL_INFO

LOG_FILE=$1

B_LOG --file ${LOG_FILE}

cd {{ nextcloud_docker_project_dir }}

INFO "Going in maintenance mode"
docker-compose exec -u www-data app ./occ maintenance:mode --on | INFO

INFO "Dumping database ..."
docker-compose exec db sh -c "mysqldump --single-transaction nextcloud > /backup/nextcloud.bak" | INFO

INFO "Dumping data ..."
docker-compose exec app rsync -aqx /var/www/html/data /backup/data | INFO

INFO "Exiting maintenance mode"
docker-compose exec -u www-data app ./occ maintenance:mode --off | INFO

exit 0