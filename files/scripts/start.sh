#!/bin/sh

ruby /home/appuser/scripts/midi-listener.rb &

cd /home/appuser/FieldStation42

VIRTUAL_ENV=/home/appuser/FieldStation42 /home/appuser/FieldStation42/bin/python3 field_player.py
