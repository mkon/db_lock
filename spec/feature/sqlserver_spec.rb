RSpec.describe 'when using mssql', db: :sqlserver do # rubocop:disable RSpec/DescribeClass
  skip_unless 'sqlserver'

  let(:name) { (0...8).map { rand(65..90).chr }.join }
  let(:timeout) { 5 }

  before(:all) do # rubocop:disable RSpec/BeforeAfterAll
    ENV['SQLSERVER_URL'] && ActiveRecord::Base.establish_connection(ENV['SQLSERVER_URL'])
  end

  it 'obtains a lock with the right name' do
    DBLock::Lock.get(name, timeout) do
      sleep 0.1
      res = ActiveRecord::Base.connection.select_one "SELECT APPLOCK_MODE ('public', '#{name}', 'Session');"
      expect(res.values.first).to eq 'Exclusive'
    end
    res = ActiveRecord::Base.connection.select_one "SELECT APPLOCK_MODE ('public', '#{name}', 'Session');"
    expect(res.values.first).to eq 'NoLock'
  end
end
