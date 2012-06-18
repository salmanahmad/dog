#
# Copyright 2011 by Salman Ahmad (salman@salmanahmad.com).
# All rights reserved.
#
# Permission is granted for use, copying, modification, distribution,
# and distribution of modified versions of this work as long as the
# above copyright notice is included.
#

require File.expand_path(File.join(File.dirname(__FILE__), '..', '..', 'test_helper.rb'))

class ParserTests::OnTest < Test::Unit::TestCase
  
  def setup
    @parser = Dog::Parser.new
    @parser.parser.root = :on
  end
  
  def test_simple
    program = <<-EOD
    
    ON EACH response DO
      PRINT 'hello, world!'
    END
    
    EOD
    
    @parser.parse(program.strip)
  end
  
  def test_in
    program = <<-EOD
    
    ON EACH offer IN offers DO
      PRINT 'hello, world!'
    END
    
    EOD
    
    @parser.parse(program.strip)
  end
  
  def test_event
    program = <<-EOD
    
    ON EACH dog.account.create DO
      PRINT 'hello, world!'
    END
    
    EOD
    
    @parser.parse(program.strip)
    
    program = <<-EOD
    
    ON EACH request IN dog.account.signin DO
      PRINT 'hello, world!'
    END
    
    EOD
    
    @parser.parse(program.strip)
  end
  
  
end