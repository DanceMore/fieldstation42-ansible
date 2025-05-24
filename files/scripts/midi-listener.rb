#!/usr/bin/env ruby

require 'json'

# Simple MIDI listener - writes JSON to socket on specific notes
# Logs debug output to a file instead of STDOUT
# Usage: ruby midi_listener.rb

MIDI_PORT = "20:0"
SOCKET_PATH = "/home/appuser/FieldStation42/runtime/channel.socket"
LOG_PATH = "/home/appuser/FieldStation42/runtime/midi_listener.log"

# Redirect STDOUT and STDERR to the log file
log_file = File.open(LOG_PATH, 'a')
log_file.sync = true
$stdout.reopen(log_file)
$stderr.reopen(log_file)

# Define what JSON to write for each note
NOTES = {
  27 => {command: "down", channel: -1},      # Channel Down
  31 => {command: "up", channel: -1}         # Channel Up
}

puts "Listening for MIDI on #{MIDI_PORT}..."

IO.popen("aseqdump -p #{MIDI_PORT}") do |midi|
  midi.each_line do |line|
    if line =~ /Note on.*note (\d+)/
      note = $1.to_i
      puts "Note pressed: #{note}"
      if data = NOTES[note]
        json = data.to_json
        puts "Writing: #{json}"
        File.write(SOCKET_PATH, json)
      end
    end
  end
end
