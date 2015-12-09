#! /usr/bin/ruby

require 'ostruct'

POMODORO_TIME = 25 # minutes

options = ARGV
if options.include?('--help') || options.include?('-h')
  puts "A simple pomodoro timer in ruby."
  puts "Usage:"
  puts "$ ruby pomodoro.rb [--time TIME]"
  puts "TIME: time (in minutes) of a single pomodoro"
  exit
end

class Pomodoro
  def initialize(options:)
    # Set pomodoro_time
    @pomodoro_time = POMODORO_TIME
    if i = options.index('--time')
      @pomodoro_time = options[i+1].to_i
      if @pomodoro_time == 0
        puts "Invalid time specified."
        exit(1)
      end
    end

    # Set pomodoro count
    @pomodoro_count = 0
  end

  def lets_go
    loop do
      run(pomodoro_chunk)
      @pomodoro_count += 1
      long_break_time? ? run(long_break_chunk) : run(short_break_chunk)
    end
  end

  def display_stats
    puts "\nYou've completed #{@pomodoro_count} full pomodoros."
    exit 0
  end

  private

  def run(chunk)
    start(chunk)
    progress(chunk.time, 20)
    finish(chunk)
  end

  def notifier
    'terminal-notifier -title "Pomodoro" -message '
  end

  def pomodoro_chunk
    OpenStruct.new(
      name: 'Pomodoro',
      time: @pomodoro_time * 60,
      message: 'Pomodoro Time is up!',
      notifier: notifier
    )
  end

  def short_break_chunk
    OpenStruct.new(
      :name => 'Short break',
      :time => 5 * 60,
      :message => 'Pomodoro Break is up!',
      :notifier => notifier
    )
  end

  def long_break_chunk
    OpenStruct.new(
      :name => 'Long break',
      :time => 15 * 60,
      :message => 'Pomodoro Break is up!',
      :notifier => notifier
    )
  end

  def start(chunk)
    puts "\n#{chunk.name}!"
    puts "started: #{Time.now.strftime('%H:%M')} (duration: #{chunk.time/60}m)"
  end

  def progress(time, number_of_updates)
    duration = 1.0 * time / number_of_updates
    progress_bar = ''

    0.upto(number_of_updates) do |i|
      percentage = (i * 1.0 / number_of_updates * 100).to_i
      progress_bar <<
        '|' <<
        '==' * i <<
        '  ' * (number_of_updates - i) <<
        "| #{percentage}%\r"

      print progress_bar
      $stdout.flush

      sleep duration
    end
  end

  def long_break_time?
    @pomodoro_count % 4 == 0
  end

  def finish(chunk)
    `#{chunk.notifier} #{chunk.message}`
  end
end

pom = Pomodoro.new(options: options)

trap('INT') { pom.display_stats }

pom.lets_go
