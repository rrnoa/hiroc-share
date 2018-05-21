#!/bin/sh

if [ -z ${AH_SITE_ENVIRONMENT+x} ]; then
  DRUSH="./docker/bin/drush"
  COMPOSER="./docker/bin/composer"
  DB_IMPORT="./docker/bin/import-db"
else
  DRUSH="./vendor/bin/drush"
  COMPOSER="composer"
  DB_IMPORT="./vendor/bin/drush sqlc <"
fi
