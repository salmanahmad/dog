#
# Copyright 2011 by Salman Ahmad (salman@salmanahmad.com).
# All rights reserved.
#
# Permission is granted for use, copying, modification, distribution,
# and distribution of modified versions of this work as long as the
# above copyright notice is included.
#

require File.expand_path(File.join(File.dirname(__FILE__), '..', '..', 'test_helper.rb'))

class ParserTests::PredicateTest < Test::Unit::TestCase
  
  def setup
    @parser = Dog::Parser.new
    @parser.parser.root = :predicate_expression
  end
  
  def test_simple_comparison
    @parser.parse("i == 5")
    @parser.parse("i.i.i == 5")
    @parser.parse("i.i.i == 'string'")
    @parser.parse("i.i.i == true")
    @parser.parse("i.i.i == {0 = 1, 1 = true, 2 = 'string'}")
    #@parser.parse("i.i.i == [1, true, 'string']")
  end
  
  def test_conditionals
    @parser.parse("a < 1")
    @parser.parse("a <= 1")
    @parser.parse("a == 1 AND b < 2 OR c > 3")
    @parser.parse("a == 1 AND (b < 2 OR c > 3)")
    @parser.parse("(a == 1 AND b < 2) OR c > 3")
    @parser.parse("(a == 1 AND (b < 2)) OR c > 3")
    @parser.parse("(a == 1 AND (b < 2)) OR c > 3 AND d == (true OR false)")
  end
  
  def test_access_in_conditionals
    @parser.parse("a == salman.friends")
    @parser.parse("a == salman.friends['happy']")
    @parser.parse("a == salman.friends.foo.bar")
  end
  
  def test_not
    @parser.parse("NOT ( i == 7)")
    @parser.parse("NOT ( i == 7  )")
    @parser.parse("NOT(i==7)")
  end
  
  def test_multiple_parenthesis
    @parser.parse("i == 5")
    @parser.parse("(i == 5)")
    @parser.parse("(((i == 5)))")
    @parser.parse("((NOT(i == 5)))")
    @parser.parse("a == 1 AND (b < 2) OR c > 4")
  end
  
  def test_multiple_logical_operators
    @parser.parse("i == 5 AND i == 5 AND i == 5")
    @parser.parse("i <= 5 AND i != 5 AND i > 5")
  end

  def test_keypath
    @parser.parse("user.i > 5 AND user.i != 5 AND user.i == 5")
  end
  
  def test_nested_expressions
    @parser.parse("user.i == i")
    @parser.parse("user.i == i[7]")
    
    # Note: You can only include an access expression, so you may be forced to wrap it in parens
    @parser.parse("user.i == (i + 6)")
    @parser.parse("user.i == (i ? x > 5)")
    
    assert_raises ::Dog::ParseError do
      @parser.parse("user.i == i + 6")
    end
    
    assert_raises ::Dog::ParseError do
      @parser.parse("user.i == i ? x > 5")
    end
    
    
  end
  
  def test_predicate
    @parser.parser.root = :predicate
    @parser.parse("WHERE age == 7")
  end
  
  
end