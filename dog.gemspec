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
  s.add_dependency 'treetop'
  s.add_dependency 'eventmachine'
  s.add_dependency 'sequel'
  s.add_dependency 'sqlite3'
  s.add_dependency 'mongo'
  s.add_dependency 'bson_ext'
  s.add_dependency 'pg'
  s.add_dependency 'thin'
  s.add_dependency 'sinatra'
  s.add_dependency 'async_sinatra'
  s.add_dependency 'tilt'
  s.add_dependency 'uuid'
  s.add_dependency 'rack-test'
  s.add_dependency 'httparty'

  s.add_dependency 'blather'

  s.add_development_dependency 'rake'

  #s.extra_rdoc_files = %w[README.rdoc]

end
