$LOAD_PATH.push File.expand_path('lib', __dir__)

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = 'db_lock'
  s.version     = ENV.fetch('VERSION', '0.8.3')
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
  s.add_development_dependency 'rubocop', '1.35.0'
  s.add_development_dependency 'rubocop-rspec', '2.12.1'
  s.add_development_dependency 'simplecov'
end
