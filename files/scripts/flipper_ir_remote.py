#!/usr/bin/env python3
"""
IR Remote Mapper - Enhanced with channel dialing, Easter eggs, and pause-based entry
Maps IR signals to standardized events with intelligent digit queue system
"""

import serial
import sys
import time
import argparse
import re
import json
import os
import subprocess
import threading
from collections import deque

SOCKET_PATH = "/home/appuser/FieldStation42/runtime/channel.socket"
LOG_PATH = "/home/appuser/FieldStation42/runtime/ir_mapper.log"

class ChannelDialer:
    def __init__(self, digit_timeout=2.5, easter_egg_timeout=1.5):
        self.digit_queue = deque()
        self.digit_timeout = digit_timeout
        self.easter_egg_timeout = easter_egg_timeout
        self.last_digit_time = 0
        self.timer = None
        self.lock = threading.Lock()
        
        # Easter egg mappings - add more as needed
        self.easter_eggs = {
            "911": self.emergency_mode,
            "666": self.demon_mode,
            "420": self.party_mode,
            "777": self.lucky_mode,
            "123": self.test_mode,
            "000": self.reset_mode,
            "404": self.error_mode,
            "80085": self.fun_mode,  # Support for longer sequences
        }
    
    def add_digit(self, digit):
        """Add a digit to the queue and manage timing"""
        with self.lock:
            self.digit_queue.append(str(digit))
            self.last_digit_time = time.time()
            
            # Cancel existing timer
            if self.timer:
                self.timer.cancel()
            
            # Check for immediate Easter egg matches (like 911)
            current_sequence = ''.join(self.digit_queue)
            if current_sequence in self.easter_eggs:
                print(f"🎯 Easter egg triggered: {current_sequence}")
                self.easter_eggs[current_sequence]()
                self.clear_queue()
                return
            
            # Set new timer for regular channel processing
            self.timer = threading.Timer(self.digit_timeout, self._process_channel)
            self.timer.start()
    
    def clear_queue(self):
        """Clear the digit queue"""
        with self.lock:
            self.digit_queue.clear()
            if self.timer:
                self.timer.cancel()
                self.timer = None
    
    def _process_channel(self):
        """Process accumulated digits as channel number"""
        with self.lock:
            if not self.digit_queue:
                return
            
            channel_str = ''.join(self.digit_queue)
            
            # Check for Easter eggs one more time
            if channel_str in self.easter_eggs:
                print(f"🎯 Easter egg triggered: {channel_str}")
                self.easter_eggs[channel_str]()
            else:
                try:
                    channel_num = int(channel_str)
                    self.tune_to_channel(channel_num)
                except ValueError:
                    print(f"❌ Invalid channel sequence: {channel_str}")
            
            self.digit_queue.clear()
            self.timer = None
    
    def tune_to_channel(self, channel):
        """Tune to specific channel number"""
        print(f"📺 Tuning to channel {channel}")
        write_json_to_socket({
            "command": "direct", 
            "channel": channel,
            "timestamp": time.time()
        })
    
    # Easter egg functions
    def emergency_mode(self):
        print("🚨 EMERGENCY MODE ACTIVATED! 🚨")
        #write_json_to_socket({
        #    "command": "easter_egg",
        #    "type": "emergency",
        #    "message": "911 Emergency Mode",
        #    "timestamp": time.time()
        #})
        #send_key_to_mpv('9')  # Could trigger special emergency feed
    
    def demon_mode(self):
        print("😈 DEMON MODE ACTIVATED! 😈")
        #write_json_to_socket({
        #    "command": "easter_egg",
        #    "type": "demon",
        #    "message": "666 Demon Mode - Spooky!",
        #    "timestamp": time.time()
        #})
        # Could activate horror/dark content filter
    
    def party_mode(self):
        print("🎉 PARTY MODE ACTIVATED! 🎉")
        #write_json_to_socket({
        #    "command": "easter_egg",
        #    "type": "party",
        #    "message": "420 Party Time!",
        #    "timestamp": time.time()
        #})
        # Could activate party music or special effects
    
    def lucky_mode(self):
        print("🍀 LUCKY MODE ACTIVATED! 🍀")
        #write_json_to_socket({
        #    "command": "easter_egg",
        #    "type": "lucky",
        #    "message": "777 Lucky Number!",
        #    "timestamp": time.time()
        #})
        # Could shuffle to random "lucky" channel
    
    def test_mode(self):
        print("🧪 TEST MODE ACTIVATED! 🧪")
        #write_json_to_socket({
        #    "command": "easter_egg",
        #    "type": "test",
        #    "message": "123 Test Sequence",
        #    "timestamp": time.time()
        #})
        # Could run system diagnostics
    
    def reset_mode(self):
        print("🔄 RESET MODE ACTIVATED! 🔄")
        #write_json_to_socket({
        #    "command": "easter_egg",
        #    "type": "reset",
        #    "message": "000 System Reset",
        #    "timestamp": time.time()
        #})
        # Could reset to default channel or restart system
    
    def error_mode(self):
        print("💥 ERROR MODE ACTIVATED! 💥")
        #write_json_to_socket({
        #    "command": "easter_egg",
        #    "type": "error",
        #    "message": "404 Not Found!",
        #    "timestamp": time.time()
        #})
        # Could show error screen or glitch effects
    
    def fun_mode(self):
        print("😄 FUN MODE ACTIVATED! 😄")
        #write_json_to_socket({
        #    "command": "easter_egg",
        #    "type": "fun",
        #    "message": "Secret fun code activated!",
        #    "timestamp": time.time()
        #})

# Global channel dialer instance
channel_dialer = ChannelDialer()

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
    channel_dialer.clear_queue()  # Clear any pending digits
    write_json_to_socket({"command": "up", "channel": -1})

def CHANNEL_DOWN():
    print("📺 Channel DOWN!")
    channel_dialer.clear_queue()  # Clear any pending digits
    write_json_to_socket({"command": "down", "channel": -1})

def EFFECT_NEXT():
    print("✨ Next effect!")
    send_key_to_mpv('c')

def EFFECT_PREV():
    print("✨ Previous effect!")
    send_key_to_mpv('z')

def VOLUME_UP():
    print("🔊 Volume UP!")
    send_key_to_mpv('0')

def VOLUME_DOWN():
    print("🔉 Volume DOWN!")
    send_key_to_mpv('9')

def MUTE():
    print("🔇 Mute toggle!")
    send_key_to_mpv('m')

def POWER():
    print("⚡ Power toggle!")
    write_json_to_socket({"command": "power_toggle", "timestamp": time.time()})

def PAUSE():
    print("⏸️  Pause/Play toggle!")
    send_key_to_mpv('space')

def INFO():
    print("ℹ️  Info display!")
    write_json_to_socket({"command": "info", "timestamp": time.time()})

def MENU():
    print("📋 Menu!")
    write_json_to_socket({"command": "menu", "timestamp": time.time()})

def OK():
    print("✅ OK/Select!")
    send_key_to_mpv('Return')

def BACK():
    print("⬅️  Back!")
    write_json_to_socket({"command": "back", "timestamp": time.time()})

# Digit handlers - these add to the channel dialer queue
def DIGIT_0():
    print("0️⃣ Digit 0")
    channel_dialer.add_digit(0)

def DIGIT_1():
    print("1️⃣ Digit 1")
    channel_dialer.add_digit(1)

def DIGIT_2():
    print("2️⃣ Digit 2")
    channel_dialer.add_digit(2)

def DIGIT_3():
    print("3️⃣ Digit 3")
    channel_dialer.add_digit(3)

def DIGIT_4():
    print("4️⃣ Digit 4")
    channel_dialer.add_digit(4)

def DIGIT_5():
    print("5️⃣ Digit 5")
    channel_dialer.add_digit(5)

def DIGIT_6():
    print("6️⃣ Digit 6")
    channel_dialer.add_digit(6)

def DIGIT_7():
    print("7️⃣ Digit 7")
    channel_dialer.add_digit(7)

def DIGIT_8():
    print("8️⃣ Digit 8")
    channel_dialer.add_digit(8)

def DIGIT_9():
    print("9️⃣ Digit 9")
    channel_dialer.add_digit(9)

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

# Enhanced remote configurations with more button mappings
REMOTE_CONFIGS = {
    "nec_0x32": {
        "protocol": "NEC",
        "address": "0x32",
        "mappings": {
            # Channel controls
            "0x11": "CHANNEL_UP",
            "0x14": "CHANNEL_DOWN",
            
            # Effects
            "0x10": "EFFECT_PREV",
            "0x12": "EFFECT_NEXT",
            
            # Digits
            "0x00": "DIGIT_0",
            "0x01": "DIGIT_1",
            "0x02": "DIGIT_2",
            "0x03": "DIGIT_3",
            "0x04": "DIGIT_4",
            "0x05": "DIGIT_5",
            "0x06": "DIGIT_6",
            "0x07": "DIGIT_7",
            "0x08": "DIGIT_8",
            "0x09": "DIGIT_9",
            
            # Volume
            "0x15": "VOLUME_UP",
            "0x16": "VOLUME_DOWN",
            "0x17": "MUTE",
            
            # Control
            "0x18": "POWER",
            "0x19": "PAUSE",
            "0x1A": "INFO",
            "0x1B": "MENU",
            "0x1C": "OK",
            "0x1D": "BACK",
        }
    },
    "samsung_tv": {
        "protocol": "Samsung32",
        "address": "0x07",
        "mappings": {
            "0x12": "CHANNEL_UP",
            "0x10": "CHANNEL_DOWN",
            "0x07": "VOLUME_UP",
            "0x0B": "VOLUME_DOWN",
            "0x0F": "MUTE",
            "0x02": "POWER",
            
            # Samsung digit mappings
            "0x04": "DIGIT_1",
            "0x05": "DIGIT_2",
            "0x06": "DIGIT_3",
            "0x08": "DIGIT_4",
            "0x09": "DIGIT_5",
            "0x0A": "DIGIT_6",
            "0x0C": "DIGIT_7",
            "0x0D": "DIGIT_8",
            "0x0E": "DIGIT_9",
            "0x11": "DIGIT_0",
        }
    },
    "sony": {
        "protocol": "SIRC",
        "address": "0x01",
        "mappings": {
            "0x10": "CHANNEL_UP",
            "0x11": "CHANNEL_DOWN",
            "0x33": "EFFECT_NEXT",
            "0x34": "EFFECT_PREV",
            "0x12": "VOLUME_UP",
            "0x13": "VOLUME_DOWN",
            "0x14": "MUTE",
            "0x15": "POWER",
            
            # Sony digit mappings
            "0x00": "DIGIT_1",
            "0x01": "DIGIT_2",
            "0x02": "DIGIT_3",
            "0x03": "DIGIT_4",
            "0x04": "DIGIT_5",
            "0x05": "DIGIT_6",
            "0x06": "DIGIT_7",
            "0x07": "DIGIT_8",
            "0x08": "DIGIT_9",
            "0x09": "DIGIT_0",
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
    parser = argparse.ArgumentParser(description='Enhanced IR Remote Event Mapper with Channel Dialing')
    parser.add_argument('--device', '-d', default='/dev/ttyACM0',
                        help='Flipper Zero serial device')
    parser.add_argument('--debug', action='store_true',
                        help='Show raw IR data')
    parser.add_argument('--debounce', '-t', type=float, default=0.7,
                        help='Debounce time in seconds')
    parser.add_argument('--digit-timeout', type=float, default=2.5,
                        help='Timeout for digit sequence in seconds')
    parser.add_argument('--log-to-file', action='store_true',
                        help='Log output to file instead of terminal')
    parser.add_argument('--verbose-unknowns', action='store_true',
                        help='Print protocol/address/command for unknown signals')
    args = parser.parse_args()

    # Set the digit timeout for the channel dialer
    global channel_dialer
    channel_dialer = ChannelDialer(digit_timeout=args.digit_timeout)

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
        print(f"Enhanced IR Remote Mapper ready on {args.device}...")
        print(f"Writing JSON to: {SOCKET_PATH}")
        print(f"Channel digit timeout: {args.digit_timeout}s")
        print("📺 Ready for channel dialing and Easter eggs!")

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
        channel_dialer.clear_queue()  # Clean up any pending timers
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
