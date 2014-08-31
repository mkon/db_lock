module DBLock
  RSpec.describe Lock do
    let(:connection) { double() }
    let(:result) { [[1]] }
    let(:name) { "custom_lock" }
    let(:timeout) { 5 }

    before do
      allow(ActiveRecord::Base).to receive(:connection).and_return(connection)
      allow(connection).to receive(:execute).and_return(result)
    end

    describe "#get" do
      it "obtians a mysql lock with the right name and timeout" do
        Lock.get(name, timeout) {}
        expect(connection).to have_received(:execute).with("SELECT GET_LOCK(:name, :timeout)", name: name, timeout: timeout)
      end

      context "when the lock was obtained" do
        let(:result) { [[1]] }

        it "passes through errors but still frees the lock" do
          expect {
            Lock.get(name, timeout){ raise "nothing" }
          }.to raise_error
          expect(connection).to have_received(:execute).with("SELECT RELEASE_LOCK(:name)", name: name)
        end

        it "executes the block" do
          expect{ |b| Lock.get(name, timeout, &b) }.to yield_control
        end
      end

      context "when the lock could not be obtained" do
        let(:result) { [[0]] }

        it "raises an error and does not execute the block" do
          x = 0
          expect { Lock.get(name, timeout){ x += 1 } }.to raise_error(DBLock::AlreadyLocked)
          expect(x).to eq(0), "the block was executed"
        end
      end
    end
  end
end
