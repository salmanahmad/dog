#
# Copyright 2011 by Salman Ahmad (salman@salmanahmad.com).
# All rights reserved.
#
# Permission is granted for use, copying, modification, distribution,
# and distribution of modified versions of this work as long as the
# above copyright notice is included.
#

require File.expand_path(File.join(File.dirname(__FILE__), '..', '..', 'test_helper.rb'))

class ParserTests::AllowTest < Test::Unit::TestCase
  
  def setup
    @parser = Dog::Parser.new
    @parser.parser.root = :allow
  end
  
  def test_users
    @parser.parse("ALLOW PEOPLE TO READ data")
    @parser.parse("ALLOW PEOPLE FROM leaners TO READ data")
    @parser.parse("ALLOW leaners TO READ data")
  end
  
  def test_modifier
    @parser.parse("ALLOW PEOPLE TO READ data")
    @parser.parse("ALLOW PEOPLE TO WRITE data")
    @parser.parse("ALLOW PEOPLE TO ACCESS data")
    @parser.parse("ALLOW PEOPLE TO JOIN community")
  end
  
  def test_profile
    @parser.parse("ALLOW PEOPLE TO READ PROFILE")
  end
  
end