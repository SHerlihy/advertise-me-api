#!/bin/bash

SCRIPT_PATH="$(dirname "$(realpath "$0")")"

rm -rf $SCRIPT_PATH/dist

mkdir $SCRIPT_PATH/dist

pip install --target $SCRIPT_PATH/dist datetime

cp $SCRIPT_PATH/lambda_function.py $SCRIPT_PATH/dist
