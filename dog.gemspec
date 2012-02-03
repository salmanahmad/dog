spec = Gem::Specification.new do |s|
  
  s.name = 'dog'
  s.version = '0.0.1'
  
  s.summary = "The Dog Programming Language"
  s.description = "The Dog Programming Language"
  
  s.author = "Salman Ahmad"
  s.email = "salman@salmanahmad.com"
  s.homepage = "http://jabber.wocky.org"
  
  s.files = Dir['lib/**/*'] + Dir['bin/**/*'] + Dir['test/**/*.rb'] + ['AUTHORS', 'LICENSE', 'README', 'dog.gemspec']
  
  s.require_paths = %w[lib]
  s.bindir = 'bin'
  
  s.executables = ['dog']
  s.default_executable = 'dog'
  
  s.has_rdoc = false
  s.add_dependency 'treetop'
  
  #s.extra_rdoc_files = %w[README.rdoc]
  
end
