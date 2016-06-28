module DBLock
  RSpec.describe Lock do
    let(:name) { (0...8).map { (65 + rand(26)).chr }.join }
    let(:timeout) { 5 }

    context "when using mssql" do
      before(:all) { DBLock.db_handler = Connection::MssqlA }

      it "obtains a mysql lock with the right name" do
        Lock.get(name, timeout) do
          res = Connection::MssqlA.connection.select_one "SELECT APPLOCK_MODE ('public', '#{name}', 'Session');"
          expect(res.values.first).to eq 'Exclusive'
        end
        res = Connection::MssqlA.connection.select_one "SELECT APPLOCK_MODE ('public', '#{name}', 'Session');"
        expect(res.values.first).to eq 'NoLock'
      end
    end

    context "when using mysql" do
      before(:all) { DBLock.db_handler = Connection::MysqlA }

      it "obtains a mysql lock with the right name" do
        Lock.get(name, timeout) do
          res = Connection::MysqlA.connection.select_one "SELECT IS_FREE_LOCK('#{name}')"
          expect(res.first.last).to eq(0)
        end
        res = Connection::MysqlA.connection.select_one "SELECT IS_FREE_LOCK('#{name}')"
        expect(res.first.last).to eq(1)
      end
    end
  end
end
