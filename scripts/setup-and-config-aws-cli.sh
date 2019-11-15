#!/usr/bin/env bash
set -e

sudo apt update
sudo apt install -y awscli

if [[ "$IS_PRODUCTION" == true ]]; then
  export AWS_ACCESS_KEY_ID=$AWS_ACCESS_KEY_ID_PROD
  export AWS_SECRET_ACCESS_KEY=$AWS_SECRET_ACCESS_KEY_PROD
  export AWS_PROFILE_NAME=$AWS_PROFILE_NAME_PROD
  export AWS_STAGE_NAME=$AWS_STAGE_NAME_PROD
else
  export AWS_ACCESS_KEY_ID=$AWS_ACCESS_KEY_ID_DEV
  export AWS_SECRET_ACCESS_KEY=$AWS_SECRET_ACCESS_KEY_DEV
  export AWS_PROFILE_NAME=$AWS_PROFILE_NAME_DEV
  export AWS_STAGE_NAME=$AWS_STAGE_NAME_DEV # TODO: maybe different stage per PR opener ?
fi
aws configure set aws_access_key_id $AWS_ACCESS_KEY_ID --profile $AWS_PROFILE_NAME
aws configure set aws_secret_access_key $AWS_SECRET_ACCESS_KEY_PROD --profile $AWS_PROFILE_NAME
echo "Exporting variables to \"$BASH_ENV\" file."
echo -e "export AWS_PROFILE_NAME=${AWS_PROFILE_NAME}" >> "$BASH_ENV"
echo -e "export AWS_STAGE_NAME=${AWS_STAGE_NAME}" >> "$BASH_ENV"
