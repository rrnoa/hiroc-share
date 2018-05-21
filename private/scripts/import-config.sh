#!/bin/sh

. ./private/scripts/commands.sh

ENV=${AH_SITE_ENVIRONMENT:-local}

$DRUSH cr
$DRUSH updb --entity-updates -y
$DRUSH cim -y
# Only import default content if told to.
if [ "$1" = "import-content" ]; then
  # We're using a custom module to create custom content. Since its only purpose
  # is to import content it doesn't need to be enabled.
  $DRUSH en aero_default_content -y
  $DRUSH pmu aero_default_content -y
fi
$DRUSH cr
