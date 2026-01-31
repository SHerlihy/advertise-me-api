#!/bin/bash

python3.14 -m venv ./.venv_test
source ./.venv_test/bin/activate

pip install -r requirements.txt
pip install -e .
