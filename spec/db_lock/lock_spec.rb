module DBLock
  RSpec.describe Lock do
    let(:name) { "custom_lock:db_lock:" + (0...8).map { (65 + rand(26)).chr }.join }
    let(:timeout) { 5 }

    describe "#get" do
      it "obtains a mysql lock with the right name" do
        Lock.get(name, timeout) do
          res = ActiveRecord::Base.connection.execute "SELECT IS_FREE_LOCK('#{name}')"
          expect(res.first.first).to eq(0)
        end
        res = ActiveRecord::Base.connection.execute "SELECT IS_FREE_LOCK('#{name}')"
        expect(res.first.first).to eq(1)
      end

      it "waits for timeout seconds" do
        ConnectionB.connection.execute "SELECT GET_LOCK('#{name}', 0)"
        time1 = Time.now
        expect { Lock.get(name, 1){ x += 1 } }.to raise_error(DBLock::AlreadyLocked)
        time2 = Time.now
        expect((time2-time1).round(1).to_s).to eq "1.0"
      end

      context "when the lock was obtained" do
        let(:result) { [[1]] }

        it "passes through errors but still frees the lock" do
          expect {
            Lock.get(name, timeout){ raise "nothing" }
          }.to raise_error
          res = ActiveRecord::Base.connection.execute "SELECT IS_FREE_LOCK('#{name}')"
          expect(res.first.first).to eq(1)
        end

        it "executes the block" do
          expect{ |b| Lock.get(name, timeout, &b) }.to yield_control
        end
      end

      context "when the lock could not be obtained" do
        it "raises an error and does not execute the block" do
          ConnectionB.connection.execute "SELECT GET_LOCK('#{name}', 0)"
          x = 0
          expect { Lock.get(name, 0){ x += 1 } }.to raise_error(DBLock::AlreadyLocked)
          expect(x).to eq(0), "the block was executed"
          ConnectionB.connection.execute "SELECT RELEASE_LOCK('#{name}')"
        end
      end
    end
  end
end
