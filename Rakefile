require 'rake'
require 'rake/testtask'

task 'default' => ['tests']

task 'tests' => ['test:units', 'test:integrations']

namespace 'test' do
  
  desc "Run all unit tests"  
  task 'units' => ['unit:parser', 'unit:compiler', 'unit:runtime']
  
  namespace 'unit' do
    Rake::TestTask.new('parser') { |t|
      t.pattern = 'test/unit/parser/*.rb'
      t.verbose = false
      t.warning = false
    }
    
    Rake::TestTask.new('compiler') { |t|
      t.pattern = 'test/unit/compiler/*.rb'
      t.verbose = false
      t.warning = false
    }
    
    Rake::TestTask.new('runtime') { |t|
      t.pattern = 'test/unit/runtime/*.rb'
      t.verbose = false
      t.warning = false
    }
  end
  
  
  desc "Run all integration tests"
  task 'integrations' => ['integration:all']
  #task 'integrations' => ['integration:parser', 'integration:compiler', 'integration:runtime']
  
  namespace 'integration' do
    Rake::TestTask.new('all') { |t|
      t.pattern = 'test/integration/*.rb'
      t.verbose = false
      t.warning = false
    }
    
    #Rake::TestTask.new('parser') { |t|
    #  t.pattern = 'test/integration/parser/*.rb'
    #  t.verbose = false
    #  t.warning = false
    #}
    #
    #Rake::TestTask.new('compiler') { |t|
    #  t.pattern = 'test/integration/compiler/*.rb'
    #  t.verbose = false
    #  t.warning = false
    #}
    #
    #Rake::TestTask.new('runtime') { |t|
    #  t.pattern = 'test/integration/runtime/*.rb'
    #  t.verbose = false
    #  t.warning = false
    #}
  end
  
end

