# frozen_string_literal: true

require_relative '../lib/log_parser'
require_relative '../lib/log_item'

RSpec.describe Assignment::LogParser do
  let(:instance) { described_class.new }

  subject { instance.parse(line) }

  let(:line) { '' }

  context 'when incomplete line is passed in' do
    let(:line) { '127.0.0.1,,' }

    it 'raises a error' do
      expect { subject }.to raise_error(Dry::Struct::Error)
    end
  end

  context 'when a valid complete line is passed in' do
    let(:line) {
      '"10.0.0.2","-","apache",1549573860,"GET /api/user HTTP/1.0",200,1234'
    }

    it 'returns a valid LogItem' do
      expect(subject).to eq(Assignment::LogItem.new(
        section: '/api',
        timestamp: 1549573860
      ))
    end
  end
end
