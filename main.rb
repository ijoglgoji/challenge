# frozen_string_literal: true

require 'optparse'

require_relative './lib/log_parser'
require_relative './lib/reader'
require_relative './lib/hits_monitor'
require_relative './lib/alerts_monitor'

def help_text
  puts 'ruby main.py -f <filename> -t <threshold> -s <statswindow>'
  puts '  filename -> absolute path of the file to monitor'
  puts '  threshold -> threshold for avg hits per 2 min window'
  puts '  statswindow -> stats window for avg hits per 2 min window'
  puts ''
  puts 'Example: ruby main.rb -f "/Users/indrajeet/MySpace/datadog/assignment/sample_csv.txt" -t 10 -s 2'
end

def parse_args
  filename = nil
  threshold = 10 # 10 hits per second
  statswindow = 10
  OptionParser.new do |parser|
    parser.on('-t', '--threshold=THRESHOLD') do |t|
      threshold = t.to_i
    end
    parser.on('-f', '--filename=FILENAME') do |f|
      filename = f
    end
    parser.on('-s', '--statswindow=STATSWINDOW') do |s|
      statswindow = s.to_i
    end
  end.parse!
  [filename, threshold, statswindow]
end

def start_queue_subscriber(queue, hits_monitor, alerts_monitor)
  Thread.new do
    loop do
      # The input argument of `false` makes the queue wait
      # till it has a element to process
      log_item = queue.pop(false)
      hits_monitor.add_hit(log_item)
      alerts_monitor.add_hit(log_item)
    end
  end
end

def start_stats_printer(hits_monitor, statswindow)
  Thread.new do
    loop do
      puts ''
      hits_monitor.print_total_hits
      hits_monitor.print_hits_by_section
      hits_monitor.reset_cache

      # Print the summaries per 10 second window
      sleep(statswindow)
    end
  end
end

def start_alerts_printer(alerts_monitor, threshold)
  Thread.new do
    loop do
      alerts_monitor.aggregate
      alerts_monitor.check(threshold)

      # Check every second so as to not delay any alerts
      sleep(1)
    end
  end
end

def main
  filename, threshold, statswindow = parse_args
  return help_text if filename.nil?

  log_parser = Assignment::LogParser.new
  reader = Assignment::Reader.new(filename, log_parser)

  # Alerts will be calculated based on the 120 second moving average
  window_in_seconds = 120 # used by the alerts monitor

  # Thread Safe Queue
  # All the log items will pass through it
  # Publisher -> Assignment::Reader class
  # Subscriber -> Assignment::HitsMonitor, Assignment::ALertsMonitor etcs
  queue = Queue.new

  # This will count total and sectional hits per time chunk (10 seconds for example)
  hits_monitor = Assignment::HitsMonitor.new

  # This will check and print alerts as required
  alerts_monitor = Assignment::AlertsMonitor.new(window_in_seconds)

  # Process the logs when they are received
  start_queue_subscriber(queue, hits_monitor, alerts_monitor)

  # Print the stats at regular intervals
  start_stats_printer(hits_monitor, statswindow)

  # Print alerts at regular intervals
  start_alerts_printer(alerts_monitor, threshold)

  # Random offset so that printing does not match log gathering
  sleep(2)

  # Start gathering the logs every second
  reader.read([queue])
end

main
