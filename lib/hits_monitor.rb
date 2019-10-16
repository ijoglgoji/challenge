# frozen_string_literal: true

module Assignment
  # This class assists with
  # - Calculating the total hits for a window of seconds
  # - Calculating the hits per section for a window of seconds
  # - Providing print api's to print hits summaries for above
  class HitsMonitor
    attr_reader :cache
    attr_reader :current_start_time
    attr_reader :mutex

    def initialize
      @cache = {}
      @mutex = Mutex.new
    end

    # Records a hit in the Hits Monitor
    def add_hit(log_item)
      @mutex.synchronize do
        @cache[log_item.section] = 1 + @cache.fetch(log_item.section, 0)
      end
    end

    def hits_by_section
      @cache
    end

    def total_hits
      @mutex.synchronize do
        hits_by_section.values.sum
      end
    end

    def reset_cache
      @mutex.synchronize do
        @cache = {}
      end
    end

    def print_hits_by_section
      @mutex.synchronize do
        puts '  Hits by Section for a 10 second window'
        hits_by_section.each do |k, v|
          puts "    Section: #{k} -> Hits: #{v}"
        end
      end
    end

    def print_total_hits
      @mutex.synchronize do
        puts '  Total hits for all sections for a 10 second window'
        puts "    Total: #{hits_by_section.values.sum}"
      end
    end
  end
end
