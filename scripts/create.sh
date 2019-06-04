#!/bin/sh

set -ex

AWS_ACCOUNTID="$(aws sts get-caller-identity --query Account --output text)"
BACKEND_BUCKET="terraform-backend-$AWS_ACCOUNTID"
REGION=${2:-ap-northeast-1}

# create backend bucket
aws s3api create-bucket --bucket $BACKEND_BUCKET --create-bucket-configuration LocationConstraint=$LEGION
aws s3api put-bucket-encryption --bucket $BACKEND_BUCKET --server-side-encryption-configuration '{
  "Rules": [
    {
      "ApplyServerSideEncryptionByDefault": {
        "SSEAlgorithm": "AES256"
      }
    }
  ]
}'

# terraform init
terraform init -backend-config="bucket=$BACKEND_BUCKET"

# SSM Parameter
aws ssm put-parameter --name "/sample-default/db/database_name" --type String --value sample
aws ssm put-parameter --name "/sample-default/db/master_username" --type String --value sample
aws ssm put-parameter --name "/sample-default/db/master_password" --type String --value samplesample

# terraform apply
terraform apply --auto-approve