#!/usr/bin/env bash

. ./private/scripts/commands.sh

if [ -z "$1" ]; then
    url="http://local.hiroc.com"
else
    url=$1
fi

$COMPOSER install
$DRUSH site-install hiroc --account-name=admin --account-pass=admin -y
$DRUSH uli --uri=$url
