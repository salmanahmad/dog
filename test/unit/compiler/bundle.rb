#
# Copyright 2011 by Salman Ahmad (salman@salmanahmad.com).
# All rights reserved.
#
# Permission is granted for use, copying, modification, distribution,
# and distribution of modified versions of this work as long as the
# above copyright notice is included.
#

require File.expand_path(File.join(File.dirname(__FILE__), '..', '..', 'test_helper.rb'))

class CompilerTests::BundleTest < Test::Unit::TestCase
  def test_simple
    program = <<-EOD
      
    i = 0
    WHILE i < 10 DO
      x = 5
      i = i + 1
    END
    
    EOD
    
    ast = ::Dog::Parser.new.parse(program)
    
    compiler = ::Dog::Compiler.new
    compiler.compile(ast)
    bundle = compiler.finalize
    
    bundle_hash = bundle.to_hash
    
    bundle = ::Dog::Bundle.from_hash(bundle_hash)
    tracks = ::Dog::Runtime.run(bundle, nil, {"config" => {"database" => "dog_unit_test"}, "database" => {"reset" => true}})
    assert_equal(5, tracks.last.variables["x"].ruby_value)
    
  end
end
