# frozen_string_literal: true

require_relative '../lib/log_item'

RSpec.describe Assignment::LogItem do
  subject { instance }

  let(:instance) { described_class.new(section: section, timestamp: timestamp) }
  let(:section) { '/api' }
  let(:timestamp) { 1 }

  context 'when section is nil' do
    let(:section) { nil }

    it 'raises a error' do
      expect { subject }.to raise_error(Dry::Struct::Error)
    end
  end

  context 'when timestamp is nil' do
    let(:timestamp) { nil }

    it 'raises a error' do
      expect { subject }.to raise_error(Dry::Struct::Error)
    end
  end

  context 'when valid params are passed in' do
    it 'returns a valid LogItem' do
      expect(subject).to eq(Assignment::LogItem.new(
        section: section,
        timestamp: timestamp
      ))
    end
  end
end
