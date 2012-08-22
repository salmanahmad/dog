spec = Gem::Specification.new do |s|

  s.name = 'dog'
  s.version = '0.0.2'

  s.summary = "The Dog Programming Language"
  s.description = "The Dog Programming Language"

  s.author = "Salman Ahmad"
  s.email = "salman@salmanahmad.com"
  s.homepage = "http://www.dog-lang.org"

  s.files = Dir['lib/**/*'] + Dir['bin/**/*'] + Dir['test/**/*.rb'] + ['AUTHORS', 'LICENSE', 'README', 'dog.gemspec']

  s.require_paths = %w[lib]
  s.bindir = 'bin'

  s.executables = ['dog']
  s.default_executable = 'dog'

  s.has_rdoc = false
  s.add_dependency 'treetop', '~> 1.4.10'
  s.add_dependency 'eventmachine', '~> 0.12.10'
  s.add_dependency 'sequel', '~> 3.37.0'
  s.add_dependency 'sqlite3', '~> 1.3.6'
  s.add_dependency 'mongo', '~> 1.6.4'
  s.add_dependency 'bson_ext', '~> 1.6.4'
  s.add_dependency 'pg', '~> 0.14.0'
  s.add_dependency 'thin', '~> 1.4.1'
  s.add_dependency 'sinatra', '~> 1.3.2'
  s.add_dependency 'async_sinatra', '~> 1.0.0'
  s.add_dependency 'tilt', '~> 1.3.3'
  s.add_dependency 'uuid', '~> 2.3.5'
  s.add_dependency 'rack-test', '~> 0.6.1'
  s.add_dependency 'httparty', '~> 0.8.3'

  s.add_dependency 'blather', '~> 0.8.0'

  s.add_development_dependency 'rake', '~> 0.9.2'
  s.add_development_dependency 'ap', '~> 0.1.1'

  #s.extra_rdoc_files = %w[README.rdoc]

end
