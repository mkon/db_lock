module DBLock
  module Adapter
    RSpec.describe Postgres, db: :postgres do
      skip_unless 'postgres'

      subject { described_class.instance }

      let(:name) { (0...8).map { rand(65..90).chr }.join }
      let(:timeout) { 5 }

      before do
        allow(DBLock).to receive(:db_handler).and_return(ModelPostgres)
      end

      def count_locks(name)
        subject.select_value "SELECT COUNT(*) FROM pg_locks WHERE locktype = 'advisory' AND objid = hashtext(?)", name
      end

      describe '#lock' do
        it 'obtains a lock with the right name' do
          expect(subject.lock(name, timeout)).to be true
          expect(count_locks(name)).to eq(1)
        end

        it 'waits for timeout seconds' do
          in_other_thread { subject.lock(name) }

          time = Benchmark.realtime do
            expect(subject.lock(name, 1)).to be false
          end
          expect(time.round(2)).to be_between(1.0, 1.1).inclusive
        end
      end

      describe '#release' do
        before { expect(subject.lock(name)).to be true } # rubocop:disable RSpec/ExpectInHook

        it 'releases a lock' do
          expect(subject.release(name)).to be true
          expect(count_locks(name)).to eq(0)
        end
      end
    end
  end
end
