#
# Copyright 2011 by Salman Ahmad (salman@salmanahmad.com).
# All rights reserved.
#
# Permission is granted for use, copying, modification, distribution,
# and distribution of modified versions of this work as long as the
# above copyright notice is included.
#

require File.expand_path(File.join(File.dirname(__FILE__), '..', '..', 'test_helper.rb'))

# TODO - Ensure that these parsed expression return the correct Tag

class ParserTests::ConfigTest < Test::Unit::TestCase
  
  def setup
    @parser = Dog::Parser.new
    @parser.parser.root = :config
  end
  
  def test_config
    @parser.parse("CONFIG server = 'localhost:3000'")
    @parser.parse("CONFIG process_count = 5")
    @parser.parse("CONFIG persist = true")
    assert_raises Dog::ParseError do
      @parser.parse("CONFIG process_count = 5 + 7")
    end
  end
  
end