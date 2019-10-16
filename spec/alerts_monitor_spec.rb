require_relative '../lib/alerts_monitor'
require_relative '../lib/log_item'

RSpec.describe Assignment::AlertsMonitor do
  let(:instance) { described_class.new(window_in_seconds) }
  let(:window_in_seconds) { 10 }
  let(:log_item) { Assignment::LogItem.new(section: '/api', timestamp: 1234) }

  describe '#initialize' do
    subject { instance }

    it 'initializes the data structures' do
      expect(instance.hits_per_second).to eq({})
      expect(instance.hits_per_window).to eq []
      expect(instance.status).to eq :not_triggered
      expect(instance.mutex).to be_a_kind_of(Mutex)
      expect(instance.window).to eq window_in_seconds
    end
  end

  describe '#add_hit' do
    subject { instance.add_hit(log_item) }

    it 'increments hits_per_second' do
      expect { subject }.to change { instance.hits_per_second }.from({}).to(1234 => 1)
    end
  end

  describe '#aggregate' do
    subject { instance.aggregate }

    it 'rolls up the hits for the second' do
      2.times { instance.add_hit(log_item) }

      subject

      expect(instance.hits_per_window).to eq [{ 1234 => 2 }]
    end
  end

  describe '#check' do
    context 'when alert is triggered' do
      let(:window_in_seconds) { 2 }
      let(:threshold) { 1 }

      before do
        3.times { instance.add_hit(Assignment::LogItem.new(section: '/api', timestamp: 0)) }
        instance.aggregate
        2.times { instance.add_hit(Assignment::LogItem.new(section: '/api', timestamp: 1)) }
        instance.aggregate
        4.times { instance.add_hit(Assignment::LogItem.new(section: '/api', timestamp: 2)) }
        instance.aggregate
      end

      it 'marks the status as :triggered' do
        expect { instance.check(threshold) }
          .to change { instance.status }
          .from(:not_triggered)
          .to(:triggered)
      end
    end

    context 'when alert is recovered' do
      let(:window_in_seconds) { 2 }
      let(:threshold) { 1 }

      before do
        3.times { instance.add_hit(Assignment::LogItem.new(section: '/api', timestamp: 1549573860)) }
        instance.aggregate
        2.times { instance.add_hit(Assignment::LogItem.new(section: '/api', timestamp: 1549573861)) }
        instance.aggregate
        4.times { instance.add_hit(Assignment::LogItem.new(section: '/api', timestamp: 1549573862)) }
        instance.aggregate

        instance.check(threshold)

        instance.aggregate
        instance.aggregate
        instance.aggregate
      end

      it 'marks the status as :triggered' do
        expect { instance.check(threshold) }
          .to change { instance.status }
          .from(:triggered)
          .to(:not_triggered)
      end
    end
  end
end
