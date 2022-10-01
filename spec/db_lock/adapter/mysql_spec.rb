module DBLock
  module Adapter
    RSpec.describe MYSQL, db: :mysql do
      skip_unless 'mysql'

      subject { described_class.instance }

      let(:name) { (0...8).map { rand(65..90).chr }.join }
      let(:timeout) { 5 }

      before do
        allow(DBLock).to receive(:db_handler).and_return(MysqlA)
      end

      describe '#lock' do
        it 'obtains a mysql lock with the right name' do
          expect(subject.lock(name, timeout)).to be true
          res = MysqlA.connection.select_one "SELECT IS_FREE_LOCK('#{name}')"
          expect(res.first.last).to eq(0)
        end

        it 'waits for timeout seconds' do
          MysqlB.connection.execute "SELECT GET_LOCK('#{name}', 0)"
          time1 = Time.now
          expect(subject.lock(name, 1)).to be false
          time2 = Time.now
          expect((time2 - time1).round(2)).to be_between(1.0, 1.1).inclusive
        end
      end

      describe '#release' do
        # rubocop:disable RSpec/ExpectInHook
        before { expect(subject.lock(name)).to be true }
        # rubocop:enable RSpec/ExpectInHook

        it 'releases a lock' do
          expect(subject.release(name)).to be true
          res = MysqlA.connection.select_one "SELECT IS_FREE_LOCK('#{name}')"
          expect(res.first.last).to eq(1)
        end
      end
    end
  end
end
