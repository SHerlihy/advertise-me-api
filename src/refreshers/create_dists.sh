#!/bin/bash

SCRIPT_PATH="$(dirname "$(realpath "$0")")"

$SCRIPT_PATH/sync_dist.sh
$SCRIPT_PATH/query_dist.sh
