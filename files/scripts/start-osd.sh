#!/bin/sh

# OSD
# TODO: this is alpha/beta/unstable still ...

# make sure we start after field-player ...
sleep 5

cd /home/appuser/FieldStation42

DISPLAY=:0 VIRTUAL_ENV=/home/appuser/FieldStation42 /home/appuser/FieldStation42/bin/python3 /home/appuser/FieldStation42/fs42/osd/main.py &
