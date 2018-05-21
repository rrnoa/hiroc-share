<?php

// Configuration directories.
$dir = dirname(DRUPAL_ROOT);
$config_directories[CONFIG_SYNC_DIRECTORY] = 'profiles/custom/hiroc/config/sync';
$split_filename_prefix = 'config_split.config_split';
$split_filepath_prefix = $config_directories[CONFIG_SYNC_DIRECTORY]  . '/' . $split_filename_prefix;
$split_envs = ['local', 'dev', 'test', 'prod', 'ci'];

// Ensure the appropriate config split is enabled.
foreach ($split_envs as $split_env) {
  $config["$split_filename_prefix.$split_env"]['status'] = FALSE;
}

/**
 * Environment detection.
 *
 * Note that the values of enviromental variables are set differently on Acquia
 * Cloud Free tier vs Acquia Cloud Professional and Enterprise.
 */
$ah_env = isset($_ENV['AH_SITE_ENVIRONMENT']) ? $_ENV['AH_SITE_ENVIRONMENT'] : NULL;
$ah_group = isset($_ENV['AH_SITE_GROUP']) ? $_ENV['AH_SITE_GROUP'] : NULL;
$is_ah_env = (bool) $ah_env;
$is_ah_prod_env = $ah_env == 'prod';
$is_ah_stage_env = ($ah_env == 'test' || $ah_env == 'stg');
$is_ah_dev_env = (preg_match('/^dev[0-9]*$/', $ah_env));
$is_ah_ode_env = (preg_match('/^ode[0-9]*$/', $ah_env));
$is_local_env = !$is_ah_env;

// Do not set split unless it is unset. This allows prior scripts to set it.
if (!isset($split)) {
  $split = 'none';

  // Non Acquia envs.
  if ($is_local_env) {
    $split = 'local';
    if (getenv('TRAVIS') || getenv('PIPELINE_ENV') || getenv('PROBO_ENVIRONMENT')) {
      $split = 'ci';
    }
  }
  // Acquia only envs.
  elseif ($is_ah_env) {
    $config_directories['vcs'] = $config_directories[CONFIG_SYNC_DIRECTORY];

    $split = 'ah_other';
    if ($is_ah_dev_env) {
      $split = 'dev';
    }
    elseif ($is_ah_stage_env) {
      $split = 'stage';
    }
    elseif ($is_ah_prod_env) {
      $split = 'prod';
    }
  }
}

if ($split != 'none' && file_exists("$split_filepath_prefix.$split.yml")) {
  $config["$split_filename_prefix.$split"]['status'] = TRUE;
}
