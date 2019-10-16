# frozen_string_literal: true

# require 'file-tail'

module Assignment
  class Reader
    def initialize(f, p)
      @filename = f
      @parser = p
    end

    def read(output_queues)
      buffer = {}
      # NOTE:
      # Looking at the sample csv file seems like the nearby
      # timestamp logs can be interspersed. Thus adding this
      # leeway field in here to assist with correctness in stats.
      # Assumption: Atleast after 4 seconds have passed, older logs
      # should not show up in the log file.
      leeway = 4 # 4 seconds worth of leeway
      start_time = nil

      File.open(@filename, 'r').each_with_index do |line, index|
        next if index.zero? # Skipping header

        log_item = @parser.parse(line)
        if index == 1 || start_time.nil?
          start_time = log_item.timestamp if index == 1 # Get the start time stamp for the file
        end

        # Read the file till the timestamp is greater than start_time
        if log_item.timestamp > start_time + leeway
          output_queues.each do |queue|
            buffer[start_time].each { |item| queue.push(item) }
          end
          buffer.delete(start_time)
          start_time = log_item.timestamp
          sleep(1)
        else
          buffer[log_item.timestamp] = buffer.fetch(log_item.timestamp, []) + [log_item]
        end
      end
    end
  end

  #############################################################################
  # This was an attempt to tail the file real time
  # Keeping it in for assignment purposes
  #############################################################################
  # NOTE:
  ## Below can be used to tail a file real time
  #
  # class Reader
  #   def initialize(f, p)
  #     @filename = f
  #     @parser = p
  #   end
  #
  #   # @param window_in_seconds [Integer] Interval for tailed data
  #   # @param output_queues [List of Queue] output_queues used by subscribers to lookup data
  #   def read(window_in_seconds, output_queues)
  #     return unless File.exist?(@filename)
  #
  #     File.open(@filename, 'r') do |f|
  #       f.extend(File::Tail)
  #       f.interval = window_in_seconds
  #       f.max_interval = 1
  #       f.backward(1)
  #       # Below retrieves data in chunks of roughly 1 second
  #       # and adds parsed log items into the output queues
  #       # for the subscribers to process
  #       f.tail do |line|
  #         next if line.nil?
  #         clean_line = line.strip.chomp
  #         next if clean_line.empty?
  #
  #         item = @parser.parse(clean_line)
  #         output_queues.each do |queue|
  #           queue.push(item)
  #         end
  #       end
  #     end
  #   end
  # end
end
