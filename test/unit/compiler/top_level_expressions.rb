#
# Copyright 2011 by Salman Ahmad (salman@salmanahmad.com).
# All rights reserved.
#
# Permission is granted for use, copying, modification, distribution,
# and distribution of modified versions of this work as long as the
# above copyright notice is included.
#

require File.expand_path(File.join(File.dirname(__FILE__), '..', '..', 'test_helper.rb'))

class CompilerTests::TopLevelExpressionsTest < Test::Unit::TestCase
  
  def setup
    @parser = Dog::Parser.new
    @compiler = Dog::Compiler.new
  end
  
  def test_simple
    assert_raises ::Dog::CompilationError do
      @compiler.compile(@parser.parse("RETURN 5"))
    end
  end
  
  def test_another_simple
    program = <<-EOD
      DEFINE foo DO
        RETURN 5
      END
    EOD

    output = @parser.parse(program)
    @compiler.compile(output)
  end
  
end
