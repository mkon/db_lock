require 'spec_helper'

module DBLock
  RSpec.describe Adapter do
    subject { Adapter }

    shared_examples "a correctly delegating adapter" do |adapter|
      before do
        allow(adapter).to receive(:lock)
        allow(adapter).to receive(:release)
      end

      it "delegates 'lock' correctly" do
        subject.lock "foo", 3
        expect(adapter).to have_received(:lock).with("foo", 3)
      end

      it "delegates 'release' correctly" do
        subject.release "foo"
        expect(adapter).to have_received(:release).with("foo")
      end
    end

    let(:connection) { double(adapter_name: adapter_name) }

    before do
      allow(DBLock).to receive(:db_handler) { double(connection: connection) }
    end

    context "when using MySQL" do
      let(:adapter_name) { 'mysql2' }

      include_examples "a correctly delegating adapter", Adapter::MYSQL.instance
    end

    context "when using Microsoft SQL Server" do
      let(:adapter_name) { 'sqlserver' }

      include_examples "a correctly delegating adapter", Adapter::Sqlserver.instance
    end
  end
end
