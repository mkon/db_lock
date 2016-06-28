require 'spec_helper'

module DBLock
  module Adapter
    RSpec.describe MYSQL do
      let(:name) { (0...8).map { (65 + rand(26)).chr }.join }
      let(:timeout) { 5 }
      subject { described_class.instance }

      before(:all) { DBLock.db_handler = Connection::MysqlA }

      describe "#lock" do
        it "obtains a mysql lock with the right name" do
          expect(subject.lock(name, timeout)).to be true
          res = Connection::MysqlA.connection.select_one "SELECT IS_FREE_LOCK('#{name}')"
          expect(res.first.last).to eq(0)
        end

        it "waits for timeout seconds" do
          Connection::MysqlB.connection.execute "SELECT GET_LOCK('#{name}', 0)"
          time1 = Time.now
          expect(subject.lock(name, 1)).to be false
          time2 = Time.now
          expect((time2-time1).round(1).to_s).to eq "1.0"
        end
      end

      describe "#release" do
        before { expect(subject.lock(name)).to be true }

        it "releases a lock" do
          expect(subject.release(name)).to be true
          res = Connection::MysqlA.connection.select_one "SELECT IS_FREE_LOCK('#{name}')"
          expect(res.first.last).to eq(1)
        end
      end
    end
  end
end
