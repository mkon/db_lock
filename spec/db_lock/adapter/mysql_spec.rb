module DBLock
  module Adapter
    RSpec.describe MYSQL, db: :mysql do
      skip_unless 'mysql'

      subject { described_class.instance }

      let(:name) { (0...8).map { rand(65..90).chr }.join }
      let(:timeout) { 5 }

      before do
        allow(DBLock).to receive(:db_handler).and_return(ModelMysql)
      end

      def is_free_lock(name)
        subject.select_value 'SELECT IS_FREE_LOCK(?)', name
      end

      describe '#lock' do
        it 'obtains a mysql lock with the right name' do
          expect {
            expect(subject.lock(name, timeout)).to be true
          }.to change { is_free_lock(name) }.from(1).to(0)
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
        before { subject.lock(name) }

        it 'releases a lock' do
          expect {
            expect(subject.release(name)).to be true
          }.to change { is_free_lock(name) }.from(0).to(1)
        end
      end
    end
  end
end
