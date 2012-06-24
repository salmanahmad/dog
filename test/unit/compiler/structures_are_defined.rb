#
# Copyright 2011 by Salman Ahmad (salman@salmanahmad.com).
# All rights reserved.
#
# Permission is granted for use, copying, modification, distribution,
# and distribution of modified versions of this work as long as the
# above copyright notice is included.
#

require File.expand_path(File.join(File.dirname(__FILE__), '..', '..', 'test_helper.rb'))

class CompilerTests::StructuresAreDefinedTest < Test::Unit::TestCase
  
  def setup
    @parser = Dog::Parser.new
    @compiler = Dog::Compiler.new
  end
  
  def test_valid
    program = <<-EOD
      DEFINE stanford = community {
        
      }
    EOD
    
    @compiler.compile(@parser.parse(program.strip))
  end
  
  def test_invalid
    program = <<-EOD
      stanford = community {
        
      }
    EOD
    
    assert_raises ::Dog::CompilationError do
      @compiler.compile(@parser.parse(program.strip))
    end
  end
  
end
