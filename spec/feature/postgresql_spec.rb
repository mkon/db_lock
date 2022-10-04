RSpec.describe 'when using postgres', db: :postgres do # rubocop:disable RSpec/DescribeClass
  skip_unless 'postgres'

  let(:name) { (0...8).map { rand(65..90).chr }.join }
  let(:timeout) { 5 }
  let(:sql_query) do
    ActiveRecord::Base.sanitize_sql_array [
      'SELECT COUNT(*) FROM pg_locks WHERE locktype = ? AND objid = hashtext(?)',
      'advisory',
      name
    ]
  end

  before(:all) do # rubocop:disable RSpec/BeforeAfterAll
    ENV['POSTGRES_URL'] && ActiveRecord::Base.establish_connection(ENV['POSTGRES_URL'])
  end

  it 'obtains a lock with the right name' do
    DBLock::Lock.get(name, 1) do
      res = ActiveRecord::Base.connection.select_one sql_query
      expect(res['count']).to eq(1)
    end
    res = ActiveRecord::Base.connection.select_one sql_query
    expect(res['count']).to eq(0)
  end
end
