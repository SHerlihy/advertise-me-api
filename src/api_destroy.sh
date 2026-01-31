#!/bin/bash

terraform -chdir=./stage destroy --auto-approve
terraform -chdir=./api_routes destroy --auto-approve
terraform -chdir=./api_resources destroy --auto-approve
terraform -chdir=./create_objects destroy --auto-approve
