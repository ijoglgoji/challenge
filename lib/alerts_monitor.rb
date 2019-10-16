# frozen_string_literal: true

module Assignment
  # This class is a very rudimentary alert manager.
  # It is responsible for
  #  - receiving http requests data from callers,
  #  - Maintaining it for a certain timeframe,
  #  - analyzing it for alert conditions
  #  - and triggering the alerts.
  #
  # We will use it to trigger alerts if avg hits per second for a 2 minute
  # window, will go above a certain threshold, for example.
  class AlertsMonitor
    # Contains the total hits per second, for the current second
    attr_reader :hits_per_window
    # Contains the total hits per second, for the current second
    attr_reader :hits_per_second
    # Represents the alert status. Whether its been triggered, or not
    attr_reader :status
    # The window size in seconds
    attr_reader :window
    # Mutex to protect above variables
    attr_reader :mutex

    # @param window_in_seconds [Integer] Alert window in seconds
    def initialize(window_in_seconds)
      @hits_per_second = {} # 0
      @hits_per_window = []
      @status = :not_triggered
      @window = window_in_seconds
      @mutex = Mutex.new
    end

    # Track a hit
    def add_hit(log_item)
      @mutex.synchronize do
        @hits_per_second[log_item.timestamp] =
          1 + @hits_per_second.fetch(log_item.timestamp, 0)
      end
    end

    # Roll up the hits_per_second, into hits_per_window
    def aggregate
      @hits_per_window.push(@hits_per_second)
      @hits_per_window.delete_at(0) if @hits_per_window.length > @window
      @hits_per_second = {} # Hits per second. This should generally contain 1 second worth of data
    end

    # Check if the threshold was crossd at some point
    # @param threshold [Inteher] Threshold for the moving average monitor
    def check(threshold)
      @mutex.synchronize do
        if triggered?(threshold)
          puts "Triggered with Average: #{average} Threshold: #{threshold} #{@window}"
          log_alert
          mark_triggered
        elsif recovered?(threshold)
          puts "Recovered with Average: #{average} Threshold: #{threshold} #{@window}"
          log_recovery
          unmark_triggered
        end
      end
    end

    private

    def triggered?(threshold)
      average > threshold && @status == :not_triggered
    end

    def recovered?(threshold)
      average <= threshold && @status == :triggered
    end

    def average
      @hits_per_window.map { |element| element.values.sum }.sum / (@window * 1.0)
    end

    def mark_triggered
      @status = :triggered
    end

    def unmark_triggered
      @status = :not_triggered
    end

    def log_alert
      start_time = @hits_per_window.map(&:keys).flatten.min
      sum = @hits_per_window.map { |element| element.values.sum }.sum
      avg = sum / @window * 1.0
      # We should ideally have a logger class
      puts 'High traffic for a 2 min avg, generated an alert - hits = ' \
        " #{avg}, triggered at #{DateTime.strptime(start_time.to_s, '%s')}"
    end

    def log_recovery
      start_time = @hits_per_window.map(&:keys).flatten.min
      return if start_time.nil?

      # We should ideally have a logger class
      puts "Recovered from alert conditions at #{DateTime.strptime(start_time.to_s, '%s')}"
    end
  end
end
