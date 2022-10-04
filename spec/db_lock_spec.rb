require 'spec_helper'

module DBLock
  RSpec.describe '.with_lock' do
    let(:name) { "custom_lock:db_lock:#{(0...8).map { rand(65..90).chr }.join}" }
    let(:timeout) { 5 }

    before do
      allow(Adapter).to receive(:lock).and_return(true)
      allow(Adapter).to receive(:release).and_return(true)
    end

    it 'uses the Adapter to receive and release the lock' do
      DBLock.with_lock(name, timeout) { sleep 0 }
      expect(Adapter).to have_received(:lock).with(name, timeout)
      expect(Adapter).to have_received(:release).with(name)
    end

    it 'limits lock names to 64 characters' do
      DBLock.with_lock("lock.name.exceeding.#{'asdf' * 10}.sixtyfour.characters", timeout) { sleep 0 }
      short_name = 'lock.name.excee-9782cc3fe0258bd32022ddfd0a24c8d4-four.characters'
      expect(Adapter).to have_received(:lock).with(short_name, timeout)
      expect(Adapter).to have_received(:release).with(short_name)
    end

    context 'when using dynamic lock names based on Rails app name' do
      # rubocop:disable RSpec/MessageChain
      before do
        allow(Rails).to receive_message_chain(:application, :class, :parent_name).and_return('Dummy')
        allow(Rails).to receive_message_chain(:application, :class, :module_parent_name).and_return('Dummy')
      end
      # rubocop:enable RSpec/MessageChain

      it 'supports lock names from rails app name' do
        DBLock.with_lock('.custom_lock', timeout) { sleep 0 }
        expect(Adapter).to have_received(:lock).with('Dummy.test.custom_lock', timeout)
        expect(Adapter).to have_received(:release).with('Dummy.test.custom_lock')
      end
    end

    context 'when the lock can be achieved' do
      before do
        allow(Adapter).to receive(:lock).and_return(true)
      end

      it 'executes the block' do
        x = 0
        DBLock.with_lock(name) { x += 1 }
        expect(x).to eq(1)
      end

      it 'passes through errors but still frees the lock' do
        expect do
          DBLock.with_lock(name, timeout) { raise 'something happened' }
        end.to raise_error(RuntimeError)
        expect(Adapter).to have_received(:release)
      end
    end

    context 'when the lock can not be achieved' do
      before do
        allow(Adapter).to receive(:lock).and_return(false)
      end

      it 'raises an error and does not execute the block' do
        x = 0
        expect { DBLock.with_lock(name, 0) { x += 1 } }.to raise_error(DBLock::AlreadyLocked)
        expect(x).to eq(0), 'the block was executed'
      end
    end
  end
end
