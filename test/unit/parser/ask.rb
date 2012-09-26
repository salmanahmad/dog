#
# Copyright 2011 by Salman Ahmad (salman@salmanahmad.com).
# All rights reserved.
#
# Permission is granted for use, copying, modification, distribution,
# and distribution of modified versions of this work as long as the
# above copyright notice is included.
#

require File.expand_path(File.join(File.dirname(__FILE__), '..', '..', 'test_helper.rb'))

class ParserTests::AskTest < Test::Unit::TestCase
  
  def setup
    @parser = Dog::Parser.new
    @parser.parser.root = :ask
  end
  
  def test_simple
    @parser.parse("ASK users TO validate")
    @parser.parse("ASK me TO validate")
    @parser.parse("ASK public TO validate")
    @parser.parse("ASK PEOPLE FROM facebook TO validate")
    @parser.parse("ASK PEOPLE FROM facebook WHERE age > 7 TO validate")
    @parser.parse("ASK PEOPLE FROM facebook WHERE age > target_age TO validate")
    @parser.parse("ASK PEOPLE FROM facebook WHERE age > target_age AND interests == 'cards' TO validate")
  end
  
  def test_user_count
    @parser.parse("ASK users TO validate")
    @parser.parse("ASK PEOPLE FROM mit TO validate")
    @parser.parse("ASK PEOPLE FROM mit WHERE age > pi TO validate")
    
    assert_raises Dog::ParseError do
      @parser.parse("ASK 3.1 PEOPLE FROM mit WHERE age > pi TO validate")
    end
    
    assert_raises Dog::ParseError do
      @parser.parse("ASK '3' PEOPLE FROM mit WHERE age > pi TO validate")
    end
  end
  
  def test_on
    @parser.parse("ASK users TO validate ON data")
    @parser.parse("ASK users TO validate THAT user HAS_FRIENDS friends")
    @parser.parse("ASK users TO validate THAT user   HAS_FRIENDS   friends")
    @parser.parse("ASK users TO validate THAT user  IS_OF_AGE    5 + 5")
  end
  
  def test_assignment
    @parser.parser.root = :program
    @parser.parse('message = ASK public TO provide_favorite_color')
    
  end
  
  
end