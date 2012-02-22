#
# Copyright 2011 by Salman Ahmad (salman@salmanahmad.com).
# All rights reserved.
#
# Permission is granted for use, copying, modification, distribution,
# and distribution of modified versions of this work as long as the
# above copyright notice is included.
#

require File.expand_path(File.join(File.dirname(__FILE__), '..', '..', 'test_helper.rb'))

class ParserTests::ListenTest < Test::Unit::TestCase
  
  def setup
    @parser = Dog::Parser.new
    @parser.parser.root = :listen
  end
  
  def test_listen_to_users
    @parser.parse("LISTEN TO PUBLIC VIA chat FOR event")
    @parser.parse("LISTEN TO ME VIA chat FOR event")
    @parser.parse("LISTEN TO students VIA email FOR event")
    @parser.parse("LISTEN TO students VIA sms FOR event")
    pp @parser.parse("LISTEN TO PEOPLE FROM mit VIA sms FOR event")
    @parser.parse("LISTEN TO PEOPLE FROM mit WHERE age > 19 VIA sms FOR event")
  end
  
  def test_listen_at
    @parser.parse("LISTEN TO PUBLIC VIA chat AT '/path' FOR event")
    @parser.parse("LISTEN TO PUBLIC VIA chat AT '/some/nested/path' FOR event")
    @parser.parse("LISTEN TO PUBLIC VIA chat AT '' FOR event")
  end
  
  def test_for_required
    assert_raise Dog::ParseError do 
      @parser.parse("LISTEN TO students VIA sms")
    end
    
    assert_raise Dog::ParseError do 
      @parser.parse("LISTEN TO students")
    end
    
    assert_raise Dog::ParseError do 
      @parser.parse("LISTEN TO ME")
    end
  end
  
  def test_for_requires_identifier
    assert_raise Dog::ParseError do 
      @parser.parse("LISTEN TO students VIA sms FOR 'happy'")
    end
  end
  
  def test_via_required
    assert_raise Dog::ParseError do 
      @parser.parse("LISTEN TO PUBLIC FOR event") 
    end
    
    assert_raise Dog::ParseError do 
      @parser.parse("LISTEN TO PUBLIC FOR event") 
    end
  end
  
end