#!/bin/bash

SCRIPT_PATH="$(dirname "$(realpath "$0")")"

rm -rf $SCRIPT_PATH/dist

mkdir $SCRIPT_PATH/dist

cp -r $SCRIPT_PATH/function/* $SCRIPT_PATH/dist
rm $SCRIPT_PATH/dist/test_snippet.py
