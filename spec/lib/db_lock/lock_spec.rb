require 'spec_helper'

module DBLock
  RSpec.describe Lock do
    let(:name) { "custom_lock:db_lock:" + (0...8).map { (65 + rand(26)).chr }.join }
    let(:timeout) { 5 }
    subject { Lock }

    # before(:all) do
    #   Db = Class.new(ActiveRecord::Base)
    #   Db.establish_connection(ENV['DATABASE_URL'])
    #   DBLock.db_handler = Db
    # end

    before do
      allow(Adapter).to receive(:lock) { true }
      allow(Adapter).to receive(:release) { true }
    end

      describe "#get" do
        it "uses the Adapter to receive and release the lock" do
          subject.get(name, timeout) {}
          expect(Adapter).to have_received(:lock).with(name, timeout)
          expect(Adapter).to have_received(:release).with(name)
        end

        it "limits lock names to 64 characters" do
          subject.get("lock.name.exceeding.#{'asdf'*10}.sixtyfour.characters", timeout) {}
          expect(Adapter).to have_received(:lock).with("lock.name.excee-9782cc3fe0258bd32022ddfd0a24c8d4-four.characters", timeout)
          expect(Adapter).to have_received(:release).with("lock.name.excee-9782cc3fe0258bd32022ddfd0a24c8d4-four.characters")
        end

        context "when the lock can be achieved" do
          before do
            allow(Adapter).to receive(:lock) { true }
          end

          it "executes the block" do
            x = 0
            subject.get(name) { x +=1 }
            expect(x).to eq(1)
          end

          it "passes through errors but still frees the lock" do
            expect {
              subject.get(name, timeout){ raise "something happened" }
            }.to raise_error(RuntimeError)
            expect(Adapter).to have_received(:release)
          end
        end

        context "when the lock can not be achieved" do
          before do
            allow(Adapter).to receive(:lock) { false }
          end

          it "raises an error and does not execute the block" do
            x = 0
            expect { Lock.get(name, 0){ x += 1 } }.to raise_error(DBLock::AlreadyLocked)
            expect(x).to eq(0), "the block was executed"
          end
        end
      end
    end
end
