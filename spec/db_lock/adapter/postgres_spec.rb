module DBLock
  module Adapter
    RSpec.describe Postgres, db: :postgres do
      skip_unless 'postgres'

      subject { described_class.instance }

      let(:name) { (0...8).map { rand(65..90).chr }.join }
      let(:timeout) { 5 }
      let(:check_query) do
        PostgresA.sanitize_sql_array [
          'SELECT COUNT(*) FROM pg_locks WHERE locktype = ? AND objid = hashtext(?)',
          'advisory',
          name
        ]
      end
      let(:lock_query) do
        PostgresA.sanitize_sql_array [
          'SELECT pg_advisory_lock(hashtext(?))',
          name
        ]
      end

      before do
        allow(DBLock).to receive(:db_handler).and_return(PostgresA)
      end

      describe '#lock' do
        it 'obtains a mysql lock with the right name' do
          expect(subject.lock(name, timeout)).to be true
          res = PostgresA.connection.select_one check_query
          expect(res['count']).to eq(1)
        end

        it 'waits for timeout seconds' do
          PostgresB.connection.execute lock_query
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
          res = PostgresA.connection.select_one check_query
          expect(res['count']).to eq(0)
        end
      end
    end
  end
end
