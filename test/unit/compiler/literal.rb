#
# Copyright 2011 by Salman Ahmad (salman@salmanahmad.com).
# All rights reserved.
#
# Permission is granted for use, copying, modification, distribution,
# and distribution of modified versions of this work as long as the
# above copyright notice is included.
#

require File.expand_path(File.join(File.dirname(__FILE__), '..', '..', 'test_helper.rb'))

module CompilerTests

class LiteralTest < Test::Unit::TestCase
  
  def setup
    @parser = Dog::Parser.new
    @parser.parser.root = :literal
    @compiler = Dog::Compiler.new
  end
  
  def compile(string)
    collar = @parser.parse(string)
    @compiler.compile(collar)
  end
  
  def test_integer
    assert_equal(compile("1"), 1)
    assert_equal(compile("-1"), -1)
    assert_equal(compile("-1000"), -1000)
    assert_equal(compile("0"), 0)
  end
  
  def test_float
    assert_equal(compile("1.1"), 1.1)
    assert_equal(compile("-1.0"), -1.0)
    assert_equal(compile("1000.45"), 1000.45)
    assert_equal(compile("0"), 0)
  end
  
  def test_string
    assert_equal(compile("'foo'"), "foo")
    assert_equal(compile("'foo\\'bar'"), "foo'bar")
  end
  
  def test_array
    assert_equal(compile("[1,2,3]"), [1,2,3])
    assert_equal(compile("[1,2,YES, NO]"), [1,2, true, false])
  end
  
  def test_hash
    assert_equal(compile("{'key':'value'}"), {"key" => "value"})
  end
  
end

end