#
# Copyright 2011 by Salman Ahmad (salman@salmanahmad.com).
# All rights reserved.
#
# Permission is granted for use, copying, modification, distribution,
# and distribution of modified versions of this work as long as the
# above copyright notice is included.
#

require File.expand_path(File.join(File.dirname(__FILE__), '..', '..', 'test_helper.rb'))

class ParserTests::NotifyTest < Test::Unit::TestCase
  
  def setup
    @parser = Dog::Parser.new
    @parser.parser.root = :notify
  end
  
  def test_users
    @parser.parse("NOTIFY me VIA email OF 'message'")
    @parser.parse("NOTIFY public VIA email OF 'message'")
    @parser.parse("NOTIFY people FROM mit VIA email OF 'message'")
    @parser.parse("NOTIFY people FROM mit WHERE major == 'CS' VIA email OF 'message'")
  end
  
  def test_of_clause
    @parser.parse("NOTIFY users VIA email OF message")
    @parser.parse("NOTIFY users VIA email OF 'message'")
    
    # TODO - The semantics here are that notify of a literal constant will 
    # create a default message with the to_string() as the body...
    @parser.parse("NOTIFY users VIA email OF '5'")
    @parser.parse("NOTIFY users VIA email OF 5")
  end
  
  def test_users_mandatory
    assert_raise Dog::ParseError do
      @parser.parse("NOTIFY OF message")
    end
  end
  
  def test_via_mandatory
    assert_raise Dog::ParseError do
      @parser.parse("NOTIFY users OF message")
    end
  end
  
  def test_notify_vs_not
    @parser.parser.root = :program
    @parser.parse("matched = NOTIFY pair VIA sms OF match")
  end
  
end