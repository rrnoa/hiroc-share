#!/usr/bin/env bash

exit_code=0

./vendor/bin/phpcs --config-set installed_paths ~/.composer/vendor/drupal/coder/coder_sniffer
./vendor/bin/phpcs -i
./vendor/bin/phpcs

exit_code=$((exit_code || $?))

exit $exit_code
