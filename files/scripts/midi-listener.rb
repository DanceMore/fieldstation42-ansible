#!/usr/bin/env ruby

require 'json'

# Simple MIDI listener - writes JSON to socket on specific notes
# Usage: ruby midi_listener.rb

MIDI_PORT = "20:0"
SOCKET_PATH = "FieldStation42/runtime/channel.socket"

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
