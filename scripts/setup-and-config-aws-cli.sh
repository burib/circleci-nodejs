#!/usr/bin/env bash
set -eou pipefail

set +u
if [ -z $IS_PRODUCTION ]; then
  IS_PRODUCTION=false
fi
set -u

if [[ "$IS_PRODUCTION" == true ]]; then
  export AWS_ACCESS_KEY_ID=${AWS_ACCESS_KEY_ID_PROD:-}
  export AWS_SECRET_ACCESS_KEY=${AWS_SECRET_ACCESS_KEY_PROD:-}
  export AWS_PROFILE_NAME=${AWS_PROFILE_NAME_PROD-default}
  export AWS_STAGE_NAME=${AWS_STAGE_NAME_PROD-prod}
elif [[ "$IS_MASTER_BRANCH" == true ]]; then
  export AWS_ACCESS_KEY_ID=${AWS_ACCESS_KEY_ID_STAGING:-}
  export AWS_SECRET_ACCESS_KEY=${AWS_SECRET_ACCESS_KEY_STAGING:-}
  export AWS_PROFILE_NAME=${AWS_PROFILE_NAME_STAGING-default}
  export AWS_STAGE_NAME=${AWS_STAGE_NAME_STAGING-staging}
else
  export AWS_ACCESS_KEY_ID=${AWS_ACCESS_KEY_ID_DEV:-}
  export AWS_SECRET_ACCESS_KEY=${AWS_SECRET_ACCESS_KEY_DEV:-}
  export AWS_PROFILE_NAME=${AWS_PROFILE_NAME_DEV-default}
  # default deployment stage is dev
  # if you want to have it deployed to your custom stage create a variable in circleCI project Environment Variables page
  # https://circleci.com/gh/USERNAME/PROJECT/edit#env-vars
  # and create a variable called AWS_STAGE_NAME_DEV with the value of $CIRCLE_USERNAME or $CIRCLE_PR_USERNAME
  # CIRCLE_USERNAME	    = The GitHub or Bitbucket username of the user who triggered the build.
  # CIRCLE_PR_USERNAME	= The GitHub or Bitbucket username of the user who created the pull request. Only available on forked PRs.
  export AWS_STAGE_NAME="$(echo ${AWS_STAGE_NAME_DEV-dev})"
fi

if [[ -z "$AWS_ACCESS_KEY_ID" || -z "$AWS_SECRET_ACCESS_KEY" ]]; then
  echo "AWS_ACCESS_KEY_ID or AWS_SECRET_ACCESS_KEY is not set in circleCI environment variables."
else
  aws configure set aws_access_key_id $AWS_ACCESS_KEY_ID --profile $AWS_PROFILE_NAME
  aws configure set aws_secret_access_key $AWS_SECRET_ACCESS_KEY_PROD --profile $AWS_PROFILE_NAME
  echo "Exporting variables to \"$BASH_ENV\" file."
  echo -e "export AWS_PROFILE_NAME=${AWS_PROFILE_NAME}" >> "$BASH_ENV"
  echo -e "export AWS_STAGE_NAME=${AWS_STAGE_NAME}" >> "$BASH_ENV"
fi


