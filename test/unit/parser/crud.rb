#
# Copyright 2011 by Salman Ahmad (salman@salmanahmad.com).
# All rights reserved.
#
# Permission is granted for use, copying, modification, distribution,
# and distribution of modified versions of this work as long as the
# above copyright notice is included.
#

require File.expand_path(File.join(File.dirname(__FILE__), '..', '..', 'test_helper.rb'))

class ParserTests::CrudTest < Test::Unit::TestCase
  
  def setup
    @parser = Dog::Parser.new
  end
  
  def test_add
    @parser.parse("ADD person TO foobars")
    @parser.parse("ADD person[0] TO foobars")
  end
  
  def test_find
    @parser.parse("FIND users WHERE age == 7")
  end
  
  def test_update
    @parser.parse("UPDATE user IN people")
  end
  
  def test_save
    @parser.parse("SAVE user TO people")
  end
  
  def test_save
    @parser.parse("REMOVE user FROM people")
  end
  
end