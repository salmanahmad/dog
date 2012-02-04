require 'rake'
require 'rake/testtask'

task 'default' => ['tests']

task 'tests' => ['test:units', 'test:integration']

namespace 'test' do
  
  desc "Run unit tests"
  Rake::TestTask.new('units') { |t|
    t.pattern = 'test/unit/**/*.rb'
    t.verbose = false
    t.warning = false
  }
  
  desc "Run integration tests"
  Rake::TestTask.new('integration') { |t|
    
  }
  
end

