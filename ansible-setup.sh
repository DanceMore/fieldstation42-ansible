#!/bin/sh

python3 -m venv .

source bin/activate

pip install -r requirements.txt

ansible-galaxy role install -r requirements.yml
