#
# Copyright 2011 by Salman Ahmad (salman@salmanahmad.com).
# All rights reserved.
#
# Permission is granted for use, copying, modification, distribution,
# and distribution of modified versions of this work as long as the
# above copyright notice is included.
#

require File.expand_path(File.join(File.dirname(__FILE__), '..', '..', 'test_helper.rb'))

class AskTest < Test::Unit::TestCase
  
  def setup
    @parser = Dog::Parser.new
    @parser.parser.root = :ask
  end
  
  def test_simple
    @parser.parse("ASK users VIA email TO validate")
    @parser.parse("ASK ME VIA email TO validate")
    @parser.parse("ASK PUBLIC VIA email TO validate")
    @parser.parse("ASK PEOPLE FROM facebook VIA email TO validate")
    @parser.parse("ASK PEOPLE FROM facebook WHERE age > 7 VIA email TO validate")
    @parser.parse("ASK PEOPLE FROM facebook WHERE age > target_age VIA email TO validate")
    @parser.parse("ASK PEOPLE FROM facebook WHERE age > target_age AND interests CONTAINS 'cards' VIA email TO validate")
  end
  
  def test_user_count
    @parser.parse("ASK 5 users VIA email TO validate")
    @parser.parse("ASK 5 PEOPLE FROM mit VIA email TO validate")
    @parser.parse("ASK 3 PEOPLE FROM mit WHERE age > pi VIA email TO validate")
    
    assert_raises Dog::ParseError do
      @parser.parse("ASK 3.1 PEOPLE FROM mit WHERE age > pi VIA email TO validate")
    end
    
    assert_raises Dog::ParseError do
      @parser.parse("ASK '3' PEOPLE FROM mit WHERE age > pi VIA email TO validate")
    end
  end
  
  def test_on
    @parser.parse("ASK users VIA email TO validate ON data")
    @parser.parse("ASK users VIA sms TO validate ON user, friends")
    @parser.parse("ASK users VIA chat TO validate ON user,friends")
  end
  
  def test_using
    @parser.parse("ASK users VIA email TO validate ON data USING force : true")
    
    assert_raises Dog::ParseError do
      @parser.parse("ASK users VIA email TO validate ON dataUSING force : true")
    end
    
  end
  
  
  def test_function_cannot_be_string
    assert_raises Dog::ParseError do
      @parser.parse("ASK 5 users VIA email TO 'validate'")
    end
  end
  
  
end