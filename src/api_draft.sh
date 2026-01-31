#!/bin/bash

AUTO=''

while getopts “a” OPTION
do
  case $OPTION in
    a)
      AUTO='--auto-approve'
      ;;
  esac
done

shift $((OPTIND - 1))

AUTH_KEY=$1
STAGE_UID=$2

if [[ -z "$AUTH_KEY" ]]; then
    read -p "Enter auth key: " AUTH_KEY
fi

if [[ -z "$STAGE_UID" ]]; then
    read -p "Enter stage uid: " STAGE_UID
fi

terraform -chdir=./create_objects init
terraform -chdir=./api_resources init
terraform -chdir=./api_routes init

case "$STAGE_UID" in
    "prod")
        ./refreshers/create_dists.sh
    ;;
    *)
        terraform -chdir=./dev_fakes init
        terraform -chdir=./dev_fakes apply --auto-approve
    ;;
esac

# CREATE RESOURCES
case "$STAGE_UID" in
    "prod")
        cat ./variables/production/bucket.txt > ./api_resources/terraform.tfvars
        cat ./variables/production/source_id.txt >> ./api_resources/terraform.tfvars
    ;;
    *)
        terraform -chdir=./dev_fakes output > ./api_resources/terraform.tfvars
        echo "source_id = \"DUMMYID\"" >> ./api_resources/terraform.tfvars
    ;;
esac

echo "auth_key = \"${AUTH_KEY}\"" >> ./api_resources/terraform.tfvars
echo "stage_uid = \"${STAGE_UID}\"" >> ./api_resources/terraform.tfvars

cat ./variables/shared/api_id.txt >> ./api_resources/terraform.tfvars
cat ./variables/shared/root_id.txt >> ./api_resources/terraform.tfvars
cat ./variables/shared/execution_arn.txt >> ./api_resources/terraform.tfvars

cat ./variables/shared/shared.txt >> ./api_resources/terraform.tfvars

terraform -chdir=./api_resources apply $AUTO

# CREATE VARIABLE OBJECTS
case "$STAGE_UID" in
    "prod")
        cat ./variables/production/bucket.txt > ./create_objects/terraform.tfvars
    ;;
    *)
        terraform -chdir=./dev_fakes output > ./create_objects/terraform.tfvars
    ;;
esac

terraform -chdir=./api_resources output >> ./create_objects/terraform.tfvars

cat ./variables/shared/api_id.txt >> ./create_objects/terraform.tfvars
cat ./variables/shared/root_id.txt >> ./create_objects/terraform.tfvars

terraform -chdir=./create_objects apply --auto-approve

# CREATE API ROUTES
terraform -chdir=./create_objects output > ./api_routes/objects.auto.tfvars
terraform -chdir=./api_resources output > ./api_routes/resources.auto.tfvars

terraform -chdir=./api_routes apply $AUTO
