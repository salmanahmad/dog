#
# Copyright 2011 by Salman Ahmad (salman@salmanahmad.com).
# All rights reserved.
#
# Permission is granted for use, copying, modification, distribution,
# and distribution of modified versions of this work as long as the
# above copyright notice is included.
#

require File.expand_path(File.join(File.dirname(__FILE__), '..', '..', 'test_helper.rb'))

class CompilerTests::NotifyTest < Test::Unit::TestCase
  def test_simple
    program = <<-EOD
      
    peeps = FIND people IN karma
    FOR EACH p IN peeps DO
      NOTIFY people.public VIA stream OF p
    END
    
    EOD
    
    ast = ::Dog::Parser.new.parse(program)
    
    compiler = ::Dog::Compiler.new
    compiler.compile(ast)
    bundle = compiler.finalize
    
  end
end
