# frozen_string_literal: true

require_relative './log_item'

module Assignment
  class LogParser
    def parse(line)
      Assignment::LogItem.new(
        section: section(line),
        timestamp: timestamp(line)
      )
    end

    private

    # Note: This can be made more generic by using the header for the files
    # to figure out the indices of the columns
    def section(line)
      columns = line.split(',')
      request_column = columns[4]
      return if request_column.nil?

      request_elements = request_column.split(' ')
      url = request_elements[1]
      return if url.nil?

      url_elements = url.split('/')
      section_string = url_elements[1]
      return if section_string.nil?

      "/" + section_string
    end

    def timestamp(line)
      columns = line.split(',')
      columns[3].to_i
    end
  end
end
