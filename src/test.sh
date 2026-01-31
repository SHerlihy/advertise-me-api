#!/bin/bash

TEST_KEY="allow"
ROOT_URL="$(terraform -chdir=./deploy output -raw api_path)"
BUCKET_NAME="$(terraform -chdir=./prepare output -raw bucket_name)"

API_URL=${ROOT_URL}/kbaas

LIST_URL="${API_URL}/list/?authKey=${TEST_KEY}"
UPLOAD_URL="${API_URL}/phrases/?authKey=${TEST_KEY}"
QUERY_URL="${API_URL}/query/?authKey=${TEST_KEY}"

echo -e "Fail on auth"
FAIL_KEY="fail"

echo -e "LIST BUCKET"
echo -e ${LIST_URL}
curl -X GET ${LIST_URL}
echo -e "\n"

echo -e "UPLOAD FILE"
echo -e ${UPLOAD_URL}
curl -X PUT --upload-file "./from_test.txt.gz" ${UPLOAD_URL}
echo -e "\n"

echo -e "Should succeed"
echo -e "LIST BUCKET"
echo -e ${LIST_URL}
curl -X GET ${LIST_URL}
echo -e "\n"

echo -e "UPLOAD FILE"
echo -e ${UPLOAD_URL}
curl -X PUT --upload-file "./from_test.txt.gz" ${UPLOAD_URL}
echo -e "\n"

echo -e "QUERY STORY"
echo -e ${QUERY_URL}
curl -X POST -H "Content-Type: application/json" -d 'Example of a story in body.' ${QUERY_URL}
echo -e "\n"

echo -e "cors"
echo -e "API"
echo -e ${API_URL}
curl -X OPTIONS ${API_URL}
echo -e "\n"

echo -e "LIST BUCKET"
echo -e ${LIST_URL}
curl -X OPTIONS ${LIST_URL}
echo -e "\n"

echo -e "UPLOAD FILE"
echo -e ${UPLOAD_URL}
curl -X OPTIONS ${UPLOAD_URL}
echo -e "\n"

echo -e "QUERY STORY"
echo -e ${QUERY_URL}
curl -X OPTIONS ${QUERY_URL}
echo -e "\n"
