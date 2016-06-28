require 'spec_helper'

module DBLock
  RSpec.describe Adapter do
    subject { Adapter }

    shared_examples "a correctly delegating adapter" do
      before do
        allow(implementation).to receive(:lock)
        allow(implementation).to receive(:release)
      end

      it "delegates 'lock' correctly" do
        subject.lock "foo", 3
        expect(implementation).to have_received(:lock).with("foo", 3)
      end

      it "delegates 'release' correctly" do
        subject.release "foo"
        expect(implementation).to have_received(:release).with("foo")
      end
    end

    context "when using MySQL" do
      before(:all) { DBLock.db_handler = Connection::MysqlA }
      let(:implementation) { Adapter::MYSQL.instance }

      it_behaves_like "a correctly delegating adapter"
    end

    context "when using Microsoft SQL Server" do
      before(:all) { DBLock.db_handler = Connection::MssqlA }
      let(:implementation) { Adapter::MSSQL.instance }

      it_behaves_like "a correctly delegating adapter"
    end
  end
end
