# HIROC

### What you need to know to set this site up locally
##### May the odds be ever in your favor
#
#


Dependencies
------------

[Docker Engine](https://docs.docker.com/engine/installation/)

[Docker Composer](https://docs.docker.com/compose/install/)


Installation
----------------

1. Install docker and docker-compose.
2. Copy `.env.example` to `.env`
3. Add the following bash function to ~/.bash_aliases if you have one, or ~/.bashrc.  This is for convenience; you can still run each script without this.
```bash
function dockerbin {
  if [ "`git rev-parse --show-cdup 2> /dev/null`" != "" ]; then
    GIT_ROOT=$(git rev-parse --show-cdup)
  else
    GIT_ROOT="."
  fi

  if [ -d "$GIT_ROOT/docker/bin" ]; then
    if [ -f "$GIT_ROOT/docker/bin/$1" ]; then
      $GIT_ROOT/docker/bin/$1 "${@:2}"
    else
      echo "That dockerbin command doesn't exist"
      return 1
    fi
  else
    echo "You must run this command from within a docker project with a docker/bin directory."
    return 1
  fi
}
```
4. Run `. ~/.bash_aliases` or `. ~/.bashrc` (wherever you added the alias) to source the file.
5. Optionally, to access the site over https, create a `~/certs` directory and generate a certificate for the site:
```
sudo openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout ~/certs/local.hiroc.com.key -out ~/certs/local.hiroc.com.crt
```
6. Copy `docroot/sites/default/example.settings.local.php` to `docroot/sites/default/settings.local.php`
7. You should now be able to run the following steps to get docker setup and running.
```bash
# Initialize the container
dockerbin build

# Start up the containers
dockerbin start
```
8. Add these host entries to /etc/hosts
```
127.0.0.1 local.hiroc.com
127.0.0.1 local.hirocdb.com
```
9. Grab the drush aliases from acquia.
10. Install the site, or update your local.
```bash
# To install:
./private/scripts/setup-local.sh

# To update:
./private/scripts/update-local.sh
```
11. For Xdebug to work, run the following:
```bash
ifconfig lo0 alias 10.254.254.254
```

Helpful Commands
----------------

Here are a few helpful commands:

```bash
# Run drush commands in the app container
dockerbin drush {command}

# Run drupal console commands in the app container
dockerbin drupal {command}

# Run composer commands in the app container
dockerbin composer {command}

# Connect to mysql shell
dockerbin mysql

# To enter the app container or execute commands on it:
dockerbin app {optional command}

# To show the container ports
dockerbin ports

# To show the container logs
dockerbin logs

# To turn Xdebug on
dockerbin debug-on

# To turn Xdebug off
dockerbin debug-off

# To import a database dump
dockerbin db-import /path/to/database/dump.sql

# To see all available commands run this from the project root
ls docker/bin
```

Notes
----------
1. Varnish is installed on the docker environment. You can bypass by going to `http://local.hiroc.com:32808`
2. You can create your own `docker-compose.local.yml` to override anything inside `docker-compose.yml`
