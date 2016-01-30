#!/usr/local/bin/ruby
require 'optparse'
require 'ostruct'
require 'awesome_print'
require 'date'

POMODORO_TIME = 5 # minutes
TMP_FILE_PATH = "/tmp/bitbar_pomodoro.txt"

class BitbarPomodoro
  def initialize(options)
    ap options
    # Default to 'check' action if nothing provided
    action = options.action || "check"

    # Read file
    @file = File.open(
      TMP_FILE_PATH,
      File.exist?(TMP_FILE_PATH) ? "r+" : "w+"
    )

    if !@file
      create_empty_file
      @status = "stopped"
    else
      @start_time, @status = @file.read.strip.split(",")
    end

    send action

    @file.close
  end

  def check
    puts "checking"
    if @status == "running"
      if DateTime.now > (DateTime.parse(@start_time) + POMODORO_TIME*60)
        stop
      else
        print_started
      end
    else
      print_ended
    end
  end

  def start
    puts "starting"
    return if @status == "running"
    @status = "running"
    @start_time = DateTime.now.to_s
    write_to_file
    print_started
  end

  def pause
    puts "pausing"
    @status = "paused"
    @start_time = Time.now
    write_to_file
    print_paused
  end

  def stop
    puts "stopping"
    @file.truncate(0)
    print_ended
  end

  def write_to_file
    puts "writing to file"
    @file.write "#{@start_time},running\n"
  end
  
  def print_started
    puts "printing started #{@start_time}"
  end

  def print_ended
    puts "printing ended"
  end
end

# Parse arguments: --start, --pause
options = OpenStruct.new
OptionParser.new do |parser|
  parser.on('-s', '--start', 'Start pomodoro') do
    options.action = "start"
  end

  parser.on('-t', '--stop', 'Stop pomodoro') do
    options.action = "stop"
  end

  parser.on('-p', '--pause', 'Pause pomodoro') do
    options.action = "pause"
  end
end.parse!

BitbarPomodoro.new(options)
