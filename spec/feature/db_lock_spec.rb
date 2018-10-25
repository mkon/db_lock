module DBLock
  RSpec.describe Lock do
    let(:name) { (0...8).map { rand(65..90).chr }.join }
    let(:timeout) { 5 }

    context 'when using mssql' do
      skip_unless 'sqlserver'

      before(:all) do
        ENV['SQLSERVER_URL'] && ActiveRecord::Base.establish_connection(ENV['SQLSERVER_URL'])
      end

      it 'obtains a lock with the right name' do
        described_class.get(name, timeout) do
          sleep 0.1
          res = ActiveRecord::Base.connection.select_one "SELECT APPLOCK_MODE ('public', '#{name}', 'Session');"
          expect(res.values.first).to eq 'Exclusive'
        end
        res = ActiveRecord::Base.connection.select_one "SELECT APPLOCK_MODE ('public', '#{name}', 'Session');"
        expect(res.values.first).to eq 'NoLock'
      end
    end

    context 'when using mysql' do
      skip_unless 'mysql'

      before(:all) do
        ENV['MYSQL_URL'] && ActiveRecord::Base.establish_connection(ENV['MYSQL_URL'])
      end

      it 'obtains a lock with the right name' do
        described_class.get(name, timeout) do
          res = ActiveRecord::Base.connection.select_one "SELECT IS_FREE_LOCK('#{name}')"
          expect(res.first.last).to eq(0)
        end
        res = ActiveRecord::Base.connection.select_one "SELECT IS_FREE_LOCK('#{name}')"
        expect(res.first.last).to eq(1)
      end
    end
  end
end
