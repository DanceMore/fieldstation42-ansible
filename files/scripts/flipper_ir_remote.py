#!/usr/bin/env python3
"""
IR Remote Mapper - Maps IR signals to standardized events
Enhanced with verbose output for unknown signals
"""

import serial
import sys
import time
import argparse
import re
import json
import os
import subprocess

SOCKET_PATH = "/home/appuser/FieldStation42/runtime/channel.socket"
LOG_PATH = "/home/appuser/FieldStation42/runtime/ir_mapper.log"

def write_json_to_socket(data):
    try:
        json_str = json.dumps(data)
        with open(SOCKET_PATH, 'w') as f:
            f.write(json_str)
        print(f"JSON written: {json_str}")
    except Exception as e:
        print(f"Error writing to socket: {e}")

def send_key_to_mpv(key):
    try:
        window_id = subprocess.check_output(
            ['xdotool', 'search', '--onlyvisible', '--class', 'mpv'],
            env={'DISPLAY': ':0'}
        ).decode().strip().split('\n')[0]
        subprocess.run(['xdotool', 'key', '--window', window_id, key], env={'DISPLAY': ':0'})
    except Exception as e:
        print(f"Failed to send key '{key}' to mpv: {e}")

def CHANNEL_UP():
    print("📺 Channel UP!")
    write_json_to_socket({"command": "up", "channel": -1})

def CHANNEL_DOWN():
    print("📺 Channel DOWN!")
    write_json_to_socket({"command": "down", "channel": -1})

def EFFECT_NEXT():
    print("✨ Next effect!")
    send_key_to_mpv('c')

def EFFECT_PREV():
    print("✨ Previous effect!")
    send_key_to_mpv('z')

def UNMAPPED_EVENT(event_name):
    print(f"❓ Unmapped event: {event_name}")

def UNKNOWN_EVENT(event_name):
    print(f"❌ Unknown event: {event_name}")

def handle_event(event_name, protocol=None, address=None, command=None, verbose=False):
    if event_name.startswith("UNMAPPED_"):
        UNMAPPED_EVENT(event_name)
    elif event_name.startswith("UNKNOWN_"):
        UNKNOWN_EVENT(event_name)
    else:
        handler = globals().get(event_name)
        if handler and callable(handler):
            handler()
        else:
            print(f"⚠️  No handler for event: {event_name}")
            write_json_to_socket({"command": "no_handler", "event": event_name})

    if verbose and protocol and address and command:
        print(f"🔍 Raw IR: protocol={protocol}, address={address}, command={command}")

REMOTE_CONFIGS = {
    "nec_0x32": {
        "protocol": "NEC",
        "address": "0x32",
        "mappings": {
            "0x11": "CHANNEL_UP",
            "0x14": "CHANNEL_DOWN",
            "0x10": "EFFECT_PREV",
            "0x12": "EFFECT_NEXT",
        }
    },
    "samsung_tv": {
        "protocol": "Samsung32",
        "address": "0x07",
        "mappings": {
            "0x12": "CHANNEL_UP",
            "0x10": "CHANNEL_DOWN"
        }
    },
}

def map_ir_signal(protocol, address, command):
    for remote_name, config in REMOTE_CONFIGS.items():
        if config["protocol"] == protocol and config["address"] == address:
            if command in config["mappings"]:
                return config["mappings"][command], protocol, address, command
            else:
                return f"UNMAPPED_{remote_name}_{command}", protocol, address, command
    return f"UNKNOWN_{protocol}_{address}_{command}", protocol, address, command

def setup_logging(log_to_file=False):
    if log_to_file:
        os.makedirs(os.path.dirname(LOG_PATH), exist_ok=True)
        log_file = open(LOG_PATH, 'a')
        sys.stdout = log_file
        sys.stderr = log_file
        return log_file
    return None

def main():
    parser = argparse.ArgumentParser(description='IR Remote Event Mapper')
    parser.add_argument('--device', '-d', default='/dev/ttyACM0',
                        help='Flipper Zero serial device')
    parser.add_argument('--debug', action='store_true',
                        help='Show raw IR data')
    parser.add_argument('--debounce', '-t', type=float, default=0.7,
                        help='Debounce time in seconds')
    parser.add_argument('--log-to-file', action='store_true',
                        help='Log output to file instead of terminal')
    parser.add_argument('--verbose-unknowns', action='store_true',
                        help='Print protocol/address/command for unknown signals')
    args = parser.parse_args()

    log_file = setup_logging(args.log_to_file)

    last_event = None
    last_event_time = 0

    try:
        os.makedirs(os.path.dirname(SOCKET_PATH), exist_ok=True)
        flipper = serial.Serial(args.device, 115200, timeout=1)
        time.sleep(3)
        flipper.flushInput()

        flipper.write(b'\x03')
        time.sleep(1)
        flipper.flushInput()

        flipper.write(b'ir rx\r\n')
        print(f"IR Remote Mapper ready on {args.device}...")
        print(f"Writing JSON to: {SOCKET_PATH}")

        while True:
            line = flipper.readline().decode('utf-8').strip()
            if not line:
                continue
            if args.debug:
                print(f"DEBUG: '{line}'")
            if any(line.startswith(h) for h in ('ir rx', 'Receiving', 'Press Ctrl+C')):
                continue
            ir_match = re.match(r'(\w+), A:(0x[0-9A-Fa-f]+), C:(0x[0-9A-Fa-f]+)', line)
            if ir_match:
                protocol, address, command = ir_match.groups()
                event, proto, addr, cmd = map_ir_signal(protocol, address, command)
                current_time = time.time()

                if event != last_event or (current_time - last_event_time) >= args.debounce:
                    handle_event(event, proto, addr, cmd, args.verbose_unknowns)
                    last_event = event
                    last_event_time = current_time

    except KeyboardInterrupt:
        print("\nMapper stopped")
    except Exception as e:
        print(f"Error: {e}")
    finally:
        try:
            flipper.close()
        except:
            pass
        if log_file:
            log_file.close()

if __name__ == "__main__":
    main()
