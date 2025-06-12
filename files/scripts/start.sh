#!/bin/sh

#ruby /home/appuser/scripts/midi-listener.rb &
python3 -u /home/appuser/scripts/flipper_ir_remote.py >> /home/appuser/FieldStation42/runtime/ir_mapper.log &

cd /home/appuser/FieldStation42

VIRTUAL_ENV=/home/appuser/FieldStation42 /home/appuser/FieldStation42/bin/python3 field_player.py >> /home/appuser/FieldStation42/runtime/player.log 2>&1
