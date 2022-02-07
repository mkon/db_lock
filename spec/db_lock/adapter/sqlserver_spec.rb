require 'spec_helper'

require_relative '../../support/connection/mssql_a'
require_relative '../../support/connection/mssql_b'

module DBLock
  module Adapter
    RSpec.describe Sqlserver, db: :sqlserver do
      skip_unless 'sqlserver'

      subject { described_class.instance }

      let(:name) { (0...8).map { rand(65..90).chr }.join }
      let(:timeout) { 5 }

      before(:all) do
        Connection::MssqlA.establish_connection ENV['SQLSERVER_URL']
        Connection::MssqlB.establish_connection ENV['SQLSERVER_URL']
      end

      before do
        allow(DBLock).to receive(:db_handler).and_return(Connection::MssqlA)
      end

      describe '#lock' do
        it 'obtains a sqlserver lock with the right name' do
          expect(subject.lock(name, timeout)).to be true
          res = Connection::MssqlA.connection.select_one "SELECT APPLOCK_MODE ('public', '#{name}', 'Session')"
          expect(res.values.first).to eq 'Exclusive'
        end

        it 'waits for timeout seconds' do
          Connection::MssqlB.connection.execute_procedure(
            'sp_getapplock',
            Resource: name,
            LockMode: 'Exclusive',
            LockOwner: 'Session',
            DbPrincipal: 'public'
          )
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
          res = Connection::MssqlA.connection.select_one "SELECT APPLOCK_MODE ('public', '#{name}', 'Session')"
          expect(res.values.first).to eq 'NoLock'
        end
      end
    end
  end
end
