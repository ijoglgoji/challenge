# frozen_string_literal: true

require 'dry-struct'
require 'dry-types'

module Types
  include Dry::Types.module
end

module Assignment
  class LogItem < Dry::Struct
    attribute :section, Types::Strict::String
    attribute :timestamp, Types::Strict::Integer
  end
end
