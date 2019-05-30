#!/bin/sh

set -ex

AWS_ACCOUNTID="$(aws sts get-caller-identity --query Account --output text)"
BACKEND_BUCKET="terraform-backend-$AWS_ACCOUNTID"

# terraform destroy
terraform destroy --auto-approve

# delete ssm Parameter
aws ssm delete-parameter --name "/sample-default/db/database_name"
aws ssm delete-parameter --name "/sample-default/db/master_username"
aws ssm delete-parameter --name "/sample-default/db/master_password"

# delete backend bucket
aws s3 rm s3://$BACKEND_BUCKET --recursive
aws s3api delete-bucket --bucket $BACKEND_BUCKET