RSpec.describe 'when using mysql', db: :mysql do # rubocop:disable RSpec/DescribeClass
  skip_unless 'mysql'

  let(:name) { (0...8).map { rand(65..90).chr }.join }
  let(:timeout) { 5 }

  before(:all) do # rubocop:disable RSpec/BeforeAfterAll
    ENV['MYSQL_URL'] && ActiveRecord::Base.establish_connection(ENV['MYSQL_URL'])
  end

  it 'obtains a lock with the right name' do
    DBLock::Lock.get(name, timeout) do
      res = ActiveRecord::Base.connection.select_one "SELECT IS_FREE_LOCK('#{name}')"
      expect(res.first.last).to eq(0)
    end
    res = ActiveRecord::Base.connection.select_one "SELECT IS_FREE_LOCK('#{name}')"
    expect(res.first.last).to eq(1)
  end
end
