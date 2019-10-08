#!/usr/bin/env bash
set -e

version_tag_pattern="v[0-9]+(\.[0-9]+)*"
if [[ $CIRCLE_TAG =~ $version_tag_pattern ]]; then
  export HAS_RELEASE_TAG=true
else
  export HAS_RELEASE_TAG=false
fi

CURRENT_BRANCH=$(git symbolic-ref HEAD | cut -d"/" -f3)
export CURRENT_HASH=$(git rev-parse HEAD)
export PRIOR_HASH=$(git log -1 --pretty=format:"%H" --no-merges)

if [[ "${CURRENT_BRANCH}" == "master" ]]; then
    export IS_MASTER_BRANCH=true
else
    export IS_MASTER_BRANCH=false
fi

if $IS_MASTER_BRANCH && $HAS_RELEASE_TAG ; then
  export IS_PRODUCTION=true
else
  export IS_PRODUCTION=false
fi

if $IS_MASTER_BRANCH && !($HAS_RELEASE_TAG) ; then
  export IS_STAGING=true
else
  export IS_STAGING=false
fi

if [ -z "$CI_PULL_REQUEST" ]
then
  export IS_PULL_REQUEST=false
else
  export IS_PULL_REQUEST=true
fi

export STAGE="dev" # default stage is dev environment                           ->  dev.example.com
if $IS_PRODUCTION ; then
  export STAGE="prod" # master + release tag goes to production environment     ->  example.com
fi
if $IS_STAGING ; then
  export STAGE="staging" # master + no release tag goes to staging environment  ->  staging.examle.com
fi
if $IS_PULL_REQUEST ; then
  export STAGE=$CIRCLE_USERNAME # pull request goes to PR opener's environment  ->  username.example.com
fi

mkdir ~/workspace
touch ~/workspace/new-env-vars
echo -e "export HAS_RELEASE_TAG=${HAS_RELEASE_TAG}" >> ~/workspace/new-env-vars
echo -e "export CURRENT_BRANCH=${CURRENT_BRANCH}" >> ~/workspace/new-env-vars
echo -e "export IS_MASTER_BRANCH=${IS_MASTER_BRANCH}" >> ~/workspace/new-env-vars
echo -e "export IS_PULL_REQUEST=${IS_PULL_REQUEST}" >> ~/workspace/new-env-vars
echo -e "export IS_PRODUCTION=${IS_PRODUCTION}" >> ~/workspace/new-env-vars
echo -e "export STAGE=${STAGE}" >> ~/workspace/new-env-vars
echo -e "export CURRENT_HASH=${CURRENT_HASH}" >> ~/workspace/new-env-vars
echo -e "export PRIOR_HASH=${PRIOR_HASH}" >> ~/workspace/new-env-vars

echo "Setting 'CURRENT_HASH' variable to: ${CURRENT_HASH}"
echo "Setting 'PRIOR_HASH' variable to: ${PRIOR_HASH}"
echo "Setting 'HAS_RELEASE_TAG' variable to: ${HAS_RELEASE_TAG}"
echo "Setting 'CURRENT_BRANCH' variable to: ${CURRENT_BRANCH}"
echo "Setting 'IS_MASTER_BRANCH' variable to: ${IS_MASTER_BRANCH}"
echo "Setting 'IS_PRODUCTION' variable to: ${IS_PRODUCTION}"
echo "Setting 'IS_STAGING' variable to: ${IS_STAGING}"
echo "Setting 'IS_PULL_REQUEST' variable to: ${IS_PULL_REQUEST}"
echo "Setting 'STAGE' variable to: ${STAGE}"

cat ~/workspace/new-env-vars >> $BASH_ENV
echo "Exporting variables to \"$BASH_ENV\" file, so we can use the variable in other jobs as well."
