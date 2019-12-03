#!/usr/bin/env bash
set -eou pipefail

CURRENT_BRANCH=$(git symbolic-ref HEAD | cut -d"/" -f3)
export CURRENT_HASH=$(git rev-parse HEAD)
export PRIOR_HASH=$(git log -1 --pretty=format:"%H" --no-merges)

set +u
if [ -z $IS_PRODUCTION ]; then
  IS_PRODUCTION=false
fi

if [ -z "$CI_PULL_REQUEST" ]
then
  export IS_PULL_REQUEST=false
else
  export IS_PULL_REQUEST=true
fi
set -u

if [[ "${CURRENT_BRANCH}" == "master" ]]; then
    export IS_MASTER_BRANCH=true
else
    export IS_MASTER_BRANCH=false
fi

export STAGE="dev" # default stage is dev environment                           ->  dev.example.com
if $IS_PRODUCTION ; then
  export STAGE="prod" # if IS_PRODUCTION variable is set, prod environment      ->  example.com
elif $IS_MASTER_BRANCH ; then
  export STAGE="staging" # master goes to staging environment at first          ->  staging.example.com
elif $IS_PULL_REQUEST ; then
  export STAGE=$CIRCLE_USERNAME # pull request goes to PR opener's environment  ->  username.example.com
fi

mkdir ~/workspace
touch ~/workspace/new-env-vars
echo -e "export CURRENT_BRANCH=${CURRENT_BRANCH}" >> ~/workspace/new-env-vars
echo -e "export IS_MASTER_BRANCH=${IS_MASTER_BRANCH}" >> ~/workspace/new-env-vars
echo -e "export IS_PULL_REQUEST=${IS_PULL_REQUEST}" >> ~/workspace/new-env-vars
echo -e "export STAGE=${STAGE}" >> ~/workspace/new-env-vars
echo -e "export CURRENT_HASH=${CURRENT_HASH}" >> ~/workspace/new-env-vars
echo -e "export PRIOR_HASH=${PRIOR_HASH}" >> ~/workspace/new-env-vars

echo "Setting 'CURRENT_HASH' variable to: ${CURRENT_HASH}"
echo "Setting 'PRIOR_HASH' variable to: ${PRIOR_HASH}"
echo "Setting 'CURRENT_BRANCH' variable to: ${CURRENT_BRANCH}"
echo "Setting 'IS_MASTER_BRANCH' variable to: ${IS_MASTER_BRANCH}"
echo "Setting 'IS_PULL_REQUEST' variable to: ${IS_PULL_REQUEST}"
echo "Setting 'STAGE' variable to: ${STAGE}"

cat ~/workspace/new-env-vars >> $BASH_ENV
echo "Exporting variables to \"$BASH_ENV\" file, so we can use them in other jobs as well."
