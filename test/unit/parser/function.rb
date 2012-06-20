#
# Copyright 2011 by Salman Ahmad (salman@salmanahmad.com).
# All rights reserved.
#
# Permission is granted for use, copying, modification, distribution,
# and distribution of modified versions of this work as long as the
# above copyright notice is included.
#

require File.expand_path(File.join(File.dirname(__FILE__), '..', '..', 'test_helper.rb'))

class ParserTests::FunctionTest < Test::Unit::TestCase
  
  def setup
    @parser = Dog::Parser.new
    @parser.parser.root = :definition
  end
  
  def test_simple
    program = <<-EOD
DEFINE function DO 
  i
END
EOD
    
    program.strip!
    @parser.parse(program)
    
  end
  
  def test_on_and_using
    
    @parser.should_clean_tree = true
    
    program = <<-EOD
DEFINE function ON input DO 




END
EOD
    
    program.strip!
    @parser.parse(program)
    
    program = <<-EOD
DEFINE function ON input USING config1 = false,config2 = false DO 




END
EOD

    program.strip!
    @parser.parse(program)
    
  end
  
end