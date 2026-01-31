#!/bin/bash

SCRIPT_PATH="$(dirname "$(realpath "$0")")"

rm -rf $SCRIPT_PATH/dist

mkdir $SCRIPT_PATH/dist

cp $SCRIPT_PATH/query_utils.py $SCRIPT_PATH/dist
cp $SCRIPT_PATH/lambda_function.py $SCRIPT_PATH/dist
