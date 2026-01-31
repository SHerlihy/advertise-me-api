#!/bin/bash

STAGE_UID=$1

terraform -chdir=./stage init

cat ./variables/shared/api_id.txt > ./stage/terraform.tfvars
echo "stage_uid = \"${STAGE_UID}\"" >> ./stage/terraform.tfvars

terraform -chdir=./stage apply
