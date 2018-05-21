#!/usr/bin/env bash

if [ -z "$ACQUIA_GITREMOTE" ]; then
    echo "This script should only be run from TravisCI."
    exit
fi

DRUSH=../vendor/drush/drush/drush
BRANCH=$(git rev-parse HEAD)_deployed_$1
COMMIT_MESSAGE=$(git log -1 --format="%s")
COMMIT_AUTHOR=$(git log -1 --format="%cn")

# Add Settings File.
if [ ! -e "docroot/sites/default/settings.php" ]; then
    cp docroot/sites/default.settings.php docroot/sites/default/settings.php
fi

echo $ACQUIA_SSH_KNOWN >> ~/.ssh/known_hosts

echo 'Preparing artifact directory...'
mkdir deploy
cd deploy
git init
git config --local core.excludesfile false
echo 'Adding git remote...'
git remote add acquia $ACQUIA_GITREMOTE
echo 'Creating build artifact...'
git checkout -b $BRANCH
rsync -a --no-g --delete --delete-excluded --exclude-from=../private/scripts/deploy/deploy-exclude.txt ../ ./ --filter 'protect /.git/'
cp ../private/scripts/deploy/.gitignore .gitignore
echo 'Pushing build artifact to remote...'
git add -A .
git commit --quiet -m "Deploy: '$COMMIT_MESSAGE' by '$COMMIT_AUTHOR'"
git fetch acquia
git push --set-upstream acquia $BRANCH

git log -1

sleep 10

curl -u "$ACQUIA_USER:$ACQUIA_PASS" -X POST "https://cloudapi.acquia.com/v1/sites/$ACQUIA_SITE/envs/$1/code-deploy.json?path=$BRANCH"

# Branch Cleanup (Keep the latest two branches per environment).
echo 'Cleaning up branches...'
BRANCHES=$(echo $(git branch -r --sort=committerdate | grep "_deployed_$1"))

IFS=' '
LATEST_BRANCH=0
read -ra ADDR <<< "$BRANCHES"
for branch in "${ADDR[@]}"; do
    if [ "$LATEST_BRANCH" -gt "1" ]; then
    	git push -d $(echo "$branch" | tr / " ")
    fi

    let LATEST_BRANCH++
done

# Rebuild cache.
echo 'Rebuilding drupal cache...'
SITE=$(echo "$ACQUIA_SITE" | cut -d':' -f2)
$DRUSH --ssh-options="-o StrictHostKeyChecking=no" @$SITE.$1 cr

# Bash doesn't support JSON all that well, using python to interpret.
DOMAINS=$(curl -u "$ACQUIA_USER:$ACQUIA_PASS" "https://cloudapi.acquia.com/v1/sites/$ACQUIA_SITE/envs/$1/domains.json" | python -c 'import json,sys;obj=json.load(sys.stdin); print " ".join([d["name"] for d in obj])')

# Clear all Varnish.
echo 'Clearing varnish...'
read -ra ADDR <<< "$DOMAINS"
for domain in "${ADDR[@]}"; do
    curl -s -u "$ACQUIA_USER:$ACQUIA_PASS" -X DELETE "https://cloudapi.acquia.com/v1/sites/$ACQUIA_SITE/envs/$1/domains/$domain/cache.json"
done

