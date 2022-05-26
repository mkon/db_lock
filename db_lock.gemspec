$LOAD_PATH.push File.expand_path('lib', __dir__)

# Maintain your gem's version:
require 'db_lock/version'

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = 'db_lock'
  s.version     = DBLock::VERSION
  s.licenses    = ['MIT']
  s.authors     = ['mkon']
  s.email       = ['konstantin@munteanu.de']
  s.homepage    = 'https://github.com/mkon/db_lock'
  s.summary     = 'Obtain manual db/mysql locks'
  s.description = 'Obtain manual db locks to guard blocks of code from parallel execution.' \
                  'Currently only supports mysql and ms-sql-server.'

  s.metadata['rubygems_mfa_required'] = 'true'

  s.files = Dir['{app,config,db,lib}/**/*', 'MIT-LICENSE', 'README.md']

  s.required_ruby_version = '>= 2.7', '< 4'

  s.add_dependency 'activerecord', '>= 6.1', '< 7.1'

  s.add_development_dependency 'rspec', '~> 3.7'
  s.add_development_dependency 'rubocop', '1.29.1'
  s.add_development_dependency 'rubocop-rspec', '2.11.1'
  s.add_development_dependency 'simplecov'
end
